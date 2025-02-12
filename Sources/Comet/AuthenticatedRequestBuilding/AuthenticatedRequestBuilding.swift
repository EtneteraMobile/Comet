//
//  AuthenticatedRequestBuilding.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

/// A type that can create authenticated `URLRequest` based on your own preferences.
public protocol AuthenticatedRequestBuilding {

    /// Creates an authenticated `URLRequest` based on your own preferences.
    ///
    /// This is where you would usually add the provided access token to the provided `URLRequest`'s header.
    ///
    /// - Parameters:
    ///   - request: Not authenticated `URLRequest`.
    ///   - token: Access token that you want to add to your `URLRequest`'s header.
    /// - Returns: Authenticated `URLRequest`.
    func authenticatedRequest(from request: URLRequest, with token: String) -> URLRequest
}
