//
//  CometClient.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

// TODO: add refresh token to CometClient
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
        responseType: ResponseObject.Type
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        authenticator.token
            .mapError { _ in CometClientError.loginRequired }
            .flatMap { [weak self] token -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performAuthorizedRequest(request, with: token)
            }
            .catch { [weak self] error -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                switch error {
                case .unauthorized:
                    return unwrappedSelf.authenticator.refreshedToken
                        .mapError { _ in CometClientError.loginRequired }
                        .flatMap{ token -> AnyPublisher<ResponseObject, CometClientError> in
                            unwrappedSelf.performAuthorizedRequest(request, with: token)
                        }
                        .eraseToAnyPublisher()
                default:
                    return Fail(error: error).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }

    public func performRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        responseType: ResponseObject.Type
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        performRequest(request)
    }
}

private extension CometClient {
    func performAuthorizedRequest<ResponseObject: Decodable>(
        _ request: URLRequest,
        with token: String
    ) -> AnyPublisher<ResponseObject, CometClientError> {
        Just(authenticatedRequestBuilder.authenticatedRequest(from: request, with: token))
            .setFailureType(to: CometClientError.self)
            .flatMap { [weak self] request -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.performRequest(request)
            }
            .eraseToAnyPublisher()
    }

    func performRequest<ResponseObject: Decodable>(_ request: URLRequest) -> AnyPublisher<ResponseObject, CometClientError> {
        URLSession.DataTaskPublisher(request: request, session: urlSession)
            .mapError(CometClientError.networkError)
            .flatMap { [weak self] output -> AnyPublisher<ResponseObject, CometClientError> in
                guard let unwrappedSelf = self else {
                    return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
                }

                return unwrappedSelf.requestResponseHandler.handleResponse(data: output.data, response: output.response)
            }
            .eraseToAnyPublisher()
    }
}
