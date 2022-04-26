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
    private let logLevel: RequestLogLevel
    private let logger: (String) -> Void

    /// TODO
    /// - Parameters:
    ///   - urlSession: TODO
    ///   - tokenProvider: TODO
    ///   - authenticatedRequestBuilder: TODO
    ///   - requestResponseHandler: TODO
    ///   - logLevel: Defines range of debug loggs
    ///   - logger: Provide custom log handler. As default log handling is used `Swift.print`
    public init(
        urlSession: URLSession = .shared,
        tokenProvider: TokenProviding,
        authenticatedRequestBuilder: AuthenticatedRequestBuilding,
        requestResponseHandler: RequestResponseHandling = CometRequestResponseHandler(),
        logLevel: RequestLogLevel = .none,
        logger: @escaping (String) -> Void = { Swift.print($0) }
    ) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(tokenProvider: tokenProvider)
        self.authenticatedRequestBuilder = authenticatedRequestBuilder
        self.requestResponseHandler = requestResponseHandler
        self.logLevel = logLevel
        self.logger = logger
    }

    /// TODO
    /// - Parameter request: TODO
    /// - Returns: TODO
    public func performAuthenticatedRequest(
        _ request: URLRequest
    ) -> AnyPublisher<Output, CometClientError> {
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
            .flatMap { [weak self] token -> AnyPublisher<Output, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performAuthenticatedRequest(request, with: token)
            }
            .catch { [weak self] error -> AnyPublisher<Output, CometClientError> in
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

    /// TODO
    /// - Parameters:
    ///   - request: TODO
    ///   - responseType: TODO
    ///   - requestResponseHandler: TODO
    /// - Returns: TODO
    public func performAuthenticatedRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        responseType: ResponseObject.Type,
        requestResponseHandler: RequestResponseHandling? = nil
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        performAuthenticatedRequest(request)
            .flatMap { [weak self] data, response -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return (requestResponseHandler ?? unwrappedSelf.requestResponseHandler)
                    .handleResponse(data: data, response: response)
            }
            .eraseToAnyPublisher()
    }
}

public extension CometClient {
    typealias Output = (data: Data, response: URLResponse)
}

private extension CometClient {
    func performAuthenticatedRequest(
        _ request: URLRequest,
        with token: String
    ) -> AnyPublisher<Output, CometClientError> {
        Just(authenticatedRequestBuilder.authenticatedRequest(from: request, with: token))
            .setFailureType(to: CometClientError.self)
            .flatMap(performRequest)
            .eraseToAnyPublisher()
    }

    func performRequest(
        _ request: URLRequest
    ) -> AnyPublisher<Output, CometClientError> {
        URLSession.DataTaskPublisher(request: request, session: urlSession)
            .debug(
                logLevel: logLevel,
                logger: logger
            )
            .mapError(CometClientError.networkError)
            .flatMap { [weak self] data, response -> AnyPublisher<Output, CometClientError> in
                guard let self = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return self.handleUnauthorizedRequest(from: (data, response))
            }
            .eraseToAnyPublisher()
    }

    func handleUnauthorizedRequest(from output: Output) -> AnyPublisher<Output, CometClientError> {
        guard let httpResponse = output.response as? HTTPURLResponse else {
            return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
        }

        return httpResponse.statusCode == 401
            ? Fail(error: CometClientError.unauthorized).eraseToAnyPublisher()
            : Just(output).setFailureType(to: CometClientError.self).eraseToAnyPublisher()
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
        case let .serverError(error):
            return .serverError(error: CometClientHttpError(code: error.code, data: error.data))
        case let .clientError(error):
            return .clientError(error: CometClientHttpError(code: error.code, data: error.data))
        case .networkError(let error):
            return .networkError(from: error)
        }
    }
}
