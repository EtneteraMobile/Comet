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
    private let unauthorizedResponseHandler: UnauthorizedResponseHandling?
    private let logConfiguration: LogConfiguration

    /// TODO
    /// - Parameters:
    ///   - urlSession: TODO
    ///   - tokenProvider: TODO
    ///   - authenticatedRequestBuilder: TODO
    ///   - requestResponseHandler: TODO
    ///   - unauthorizedResponseHandler: handler for processing the 401 response to determine how it should be processed.
    ///   - logConfiguration:
    ///         `logLevel`: Defines range of debug logs
    ///         `logger`: Provide custom log handler. As default log handling is used `Swift.print`
    public init(
        urlSession: URLSession = .shared,
        tokenProvider: TokenProviding,
        authenticatedRequestBuilder: AuthenticatedRequestBuilding,
        requestResponseHandler: RequestResponseHandling = CometRequestResponseHandler(),
        unauthorizedResponseHandler: UnauthorizedResponseHandling? = nil,
        logConfiguration: LogConfiguration = .init(
            logLevel: .none,
            logger: { Swift.print($0) }
        )
    ) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(tokenProvider: tokenProvider)
        self.authenticatedRequestBuilder = authenticatedRequestBuilder
        self.requestResponseHandler = requestResponseHandler
        self.unauthorizedResponseHandler = unauthorizedResponseHandler
        self.logConfiguration = logConfiguration
    }

    /// TODO
    /// - Parameter request: TODO
    /// - Returns: TODO
    public func performAuthenticatedRequest(
        _ request: URLRequest
    ) -> AnyPublisher<Output, CometClientError> {
        authenticator
        .accessToken
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
            case let .unauthorized(httpResponseError):
                if let unauthorizedResponseHandler = unwrappedSelf.unauthorizedResponseHandler {
                    return unauthorizedResponseHandler
                    .handleResponse(response: httpResponseError.response, data: httpResponseError.data)
                    .flatMap { _ in
                        unwrappedSelf.refreshToken(request)
                    }
                    .eraseToAnyPublisher()
                } else {
                    return unwrappedSelf.refreshToken(request)
                }
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

    private func refreshToken(_ request: URLRequest) -> AnyPublisher<Output, CometClientError> {
        authenticator
        .refreshAccessToken
        .mapError { $0.cometClientError }
        .flatMap { [weak self] token -> AnyPublisher<Output, CometClientError> in
            guard let unwrappedSelf = self else {
                return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
            }
            return unwrappedSelf.performAuthenticatedRequest(request, with: token)
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
                logLevel: logConfiguration.logLevel,
                logger: logConfiguration.logger
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

        if httpResponse.statusCode == 401 {
            return Fail(
                error: CometClientError.unauthorized(
                    error: CometClientHttpResponseError(response: output.response, data: output.data)
                )
            ).eraseToAnyPublisher()
        }

        return Just(output).setFailureType(to: CometClientError.self).eraseToAnyPublisher()
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
