//
//  AuthenticatorError.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

enum AuthenticatorError: Error {
    case noValidToken
    case internalError
    case loginRequired
    case serverError(error: AuthenticatorHttpError)
    case clientError(error: AuthenticatorHttpError)
    case networkError(from: URLError)
}
