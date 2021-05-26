//
//  TokenProviding.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

// TODO: add more information about accessToken and refreshAccessToken

/// Provides access tokens for the [HTTPClient](x-source-tag://HTTPClient).
///
/// This is where you either load access tokens from the local storage (e.g. `Keychain`)
/// or refresh access tokens.
///
/// - Tag: TokenProviding
public protocol TokenProviding {

    /// Publisher that emits either access token or `TokenManagingError`, if there is no access token.
    ///
    /// This is where you usually load the access token from the local storage (e. g. `Keychain`).
    /// You do not have to worry about or check the validity of the token.
    /// The [HTTPClient](x-source-tag://HTTPClient) will automatically request a refreshed token, if the access token is not valid anymore.
    var accessToken: AnyPublisher<String, TokenProvidingError> { get }

    /// Publisher that forces a refresh of the access token and then emits either the new access token or `TokenManagingError`, if there is no access token.
    ///
    /// This is where you usually request a new access token from a backend.
    var refreshAccessToken: AnyPublisher<String, TokenProvidingError> { get }
}
