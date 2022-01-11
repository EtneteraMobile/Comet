//
//  Authenticator.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

/// TODO
final class Authenticator {
    private let tokenProvider: TokenProviding
    private let queue = DispatchQueue(label: "Authenticator-\(UUID().uuidString)")
    private var refreshTokenPublisher: AnyPublisher<String, AuthenticatorError>?

    init(tokenProvider: TokenProviding) {
        self.tokenProvider = tokenProvider
    }

    /// TODO
    var accessToken: AnyPublisher<String, AuthenticatorError> {
        queue.sync { [weak self] in
            guard let unwrappedSelf = self else {
                return Fail(error: AuthenticatorError.internalError).eraseToAnyPublisher()
            }

            if let publisher = unwrappedSelf.refreshTokenPublisher {
                return publisher
            }

            return unwrappedSelf.tokenProvider.accessToken
                .mapError { $0.authenticatorError }
                .eraseToAnyPublisher()
        }
    }

    /// TODO
    var refreshAccessToken: AnyPublisher<String, AuthenticatorError> {
        queue.sync { [weak self] in
            guard let unwrappedSelf = self else {
                return Fail(error: AuthenticatorError.internalError).eraseToAnyPublisher()
            }

            if let publisher = unwrappedSelf.refreshTokenPublisher {
                return publisher
            }

            let publisher = unwrappedSelf.tokenProvider.refreshAccessToken
                .mapError { $0.authenticatorError }
                .handleEvents(receiveCompletion: { _ in
                    unwrappedSelf.refreshTokenPublisher = nil
                })
                .share(replay: 1)
                .eraseToAnyPublisher()

            unwrappedSelf.refreshTokenPublisher = publisher

            return publisher
        }
    }
}

fileprivate extension TokenProvidingError {
    var authenticatorError: AuthenticatorError {
        switch self {
        case .noToken:
            return .noValidToken
        case .invalidToken:
            return .noValidToken
        case .loginRequired:
            return .loginRequired
        case let .serverError(code, data):
            return .serverError(code: code, data: data)
        case let .clientError(code, data):
            return .clientError(code: code, data: data)
        case .internalError:
            return .internalError
        case .networkError(let error):
            return .networkError(from: error)
        }
    }
}
