//
//  CometClient.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

/// TODO
/// - Tag: CometClient
public final class CometClient {
    private let urlSession: URLSession
    private let authenticator: Authenticator
    private let authenticatedRequestBuilder: AuthenticatedRequestBuilding
    private let requestResponseHandler: RequestResponseHandling

    /// TODO
    /// - Parameters:
    ///   - urlSession: TODO
    ///   - tokenProvider: TODO
    ///   - authenticatedRequestBuilder: TODO
    ///   - requestResponseHandler: TODO
    public init(
        urlSession: URLSession = .shared,
        tokenProvider: TokenProviding,
        authenticatedRequestBuilder: AuthenticatedRequestBuilding,
        requestResponseHandler: RequestResponseHandling = CometRequestResponseHandler()
    ) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(tokenProvider: tokenProvider)
        self.authenticatedRequestBuilder = authenticatedRequestBuilder
        self.requestResponseHandler = requestResponseHandler
    }

    /// TODO
    /// - Parameter request: TODO
    /// - Returns: TODO
    public func performAuthenticatedRequest(
        _ request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> {
        authenticator.accessToken
            .catch { [weak self] error -> AnyPublisher<String, AuthenticatorError> in
                switch error {
                case .noValidToken:
                    guard let unwrappedSelf = self else {
                        return Fail(error: AuthenticatorError.internalError).eraseToAnyPublisher()
                    }

                    return unwrappedSelf.authenticator.refreshAccessToken
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .mapError { $0.cometClientError }
            .flatMap { [weak self] token -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performAuthenticatedRequest(request, with: token)
            }
            .catch { [weak self] error -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                switch error {
                case .unauthorized:
                    return unwrappedSelf.authenticator.refreshAccessToken
                        .mapError { $0.cometClientError }
                        .flatMap { token in
                            unwrappedSelf.performAuthenticatedRequest(request, with: token)
                        }
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
}

private extension CometClient {
    func performAuthenticatedRequest(
        _ request: URLRequest,
        with token: String
    ) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> {
        Just(authenticatedRequestBuilder.authenticatedRequest(from: request, with: token))
            .setFailureType(to: CometClientError.self)
            .flatMap(performRequest)
            .eraseToAnyPublisher()
    }

    func performRequest(
        _ request: URLRequest
    ) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> {
        URLSession.DataTaskPublisher(request: request, session: urlSession)
            .debug()
            .mapError(CometClientError.networkError)
            .flatMap { [weak self] (data: Data, response: URLResponse) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> in
                guard let self = self else {
                    return Fail(error: .internalError).eraseToAnyPublisher()
                }

                return self.requestResponseHandler.handleResponse(data: data, response: response)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}

fileprivate extension AuthenticatorError {
    var cometClientError: CometClientError {
        switch self {
        case .noValidToken:
            return .loginRequired
        case .internalError:
            return .internalError
        case .loginRequired:
            return .loginRequired
        case .internalServerError:
            return .internalServerError
        case let .httpError(code, data):
            return .httpError(code: code, data: data)
        case .networkError(let error):
            return .networkError(from: error)
        }
    }
}
