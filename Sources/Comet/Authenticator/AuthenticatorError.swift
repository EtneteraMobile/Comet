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
    case serverError(code: Int, data: Data)
    case clientError(code: Int, data: Data)
    case networkError(from: URLError)
}
