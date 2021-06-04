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

    public init(
        urlSession: URLSession = .shared,
        tokenProvider: TokenProviding,
        authorizedRequestBuilder: AuthenticatedRequestBuilding,
        requestResponseHandler: RequestResponseHandling = CometRequestResponseHandler()
    ) {
        self.urlSession = urlSession
        self.authenticator = Authenticator(tokenProvider: tokenProvider)
        self.authenticatedRequestBuilder = authorizedRequestBuilder
        self.requestResponseHandler = requestResponseHandler
    }

    public func performAuthenticatedRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        responseType: ResponseObject.Type,
        requestResponseHandler: RequestResponseHandling? = nil
    ) -> AnyPublisher<ResponseObject, CometClientError> {
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
            .flatMap { [weak self] token -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performAuthorizedRequest(
                    request,
                    with: token,
                    requestResponseHandler: requestResponseHandler ?? unwrappedSelf.requestResponseHandler
                )
            }
            .catch { [weak self] error -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                switch error {
                case .unauthorized:
                    return unwrappedSelf.authenticator.refreshAccessToken
                        .mapError { $0.cometClientError }
                        .flatMap{ token -> AnyPublisher<ResponseObject, CometClientError> in
                            unwrappedSelf.performAuthorizedRequest(
                                request, with: token,
                                requestResponseHandler: requestResponseHandler ?? unwrappedSelf.requestResponseHandler
                            )
                        }
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    // TODO: implement
    public func performAuthenticatedRequest(_ request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> {



        return Empty().eraseToAnyPublisher()
    }
}

private extension CometClient {
    func performAuthorizedRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        with token: String,
        requestResponseHandler: RequestResponseHandling
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        Just(authenticatedRequestBuilder.authenticatedRequest(from: request, with: token))
            .setFailureType(to: CometClientError.self)
            .flatMap { [weak self] request -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performRequest(request, requestResponseHandler: requestResponseHandler)
            }
            .eraseToAnyPublisher()
    }

    func performRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        requestResponseHandler: RequestResponseHandling
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        URLSession.DataTaskPublisher(request: request, session: urlSession)
            .mapError(CometClientError.networkError)
            .flatMap { output in
                requestResponseHandler.handleResponse(data: output.data, response: output.response)
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
        case .httpError(let code):
            return .httpError(code: code)
        case .networkError(let error):
            return .networkError(from: error)
        }
    }
}
