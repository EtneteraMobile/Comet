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

    /// Internal server error.
    ///
    /// Use this error, if a server returns internal server error (status code 500),
    /// when refreshing the access token.
    case internalServerError

    /// HTTP error.
    case httpError(code: Int, data: Data)

    /// TODO
    case networkError(from: URLError)
}
