//
//  TokenProvidingError.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

/// Describes errors in [TokenProviding](x-source-tag://TokenProviding) domain.
public enum TokenProvidingError: Error {

    /// No access token found.
    case noToken

    /// The access token is invalid.
    case invalidToken

    /// No access token and refresh token found.
    ///
    /// Use this error, if you are sure that login is required.
    case loginRequired

    /// Internal error.
    ///
    /// Use this error, if
    case internalError

    /// Server error.
    ///
    /// Use this error, if a server returns server error (status codes 5xx),
    /// when refreshing the access token.
    case serverError(error: TokenProvidingHttpError)

    /// client error (status codes 4xx).
    case clientError(error: TokenProvidingHttpError)

    /// TODO
    case networkError(from: URLError)
}
