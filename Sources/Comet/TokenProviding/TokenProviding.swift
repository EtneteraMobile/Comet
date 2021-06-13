//
//  TokenProviding.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

/// Provides access tokens for the [CometClient](x-source-tag://CometClient).
///
/// This is where you either load access tokens from the local storage (e.g. `Keychain`) or refresh access tokens.
public protocol TokenProviding {

    /// Publisher that emits either access token or `TokenProvidingError`.
    ///
    /// This is where you usually load the access token from the local storage (e. g. `Keychain`).
    /// You can try to validate the access token and return a `TokenProvidingError` if needed.
    /// Or just load the access token from the local storage,
    /// and [CometClient](x-source-tag://CometClient) will automatically request a refreshed access token if needed.
    ///
    /// - Attention: Never try to refresh the access token on your own if the token is invalid.
    /// This will lead to a race condition and the [CometClient](x-source-tag://CometClient) won't behave appropriately.
    var accessToken: AnyPublisher<String, TokenProvidingError> { get }

    /// Publisher that emits either refreshed access token or `TokenProvidingError`.
    ///
    /// This is where you usually request a new access token from a backend or perform ilent login if possible.
    var refreshAccessToken: AnyPublisher<String, TokenProvidingError> { get }
}
