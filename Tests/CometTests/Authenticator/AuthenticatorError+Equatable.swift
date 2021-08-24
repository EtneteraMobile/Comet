//
//  File.swift
//  Comet
//
//  Created by Tuan Tu Do on 12.06.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

@testable import Comet
import Foundation

extension AuthenticatorError: Equatable {
    public static func == (lhs: AuthenticatorError, rhs: AuthenticatorError) -> Bool {
        switch (lhs, rhs) {
        case (.noValidToken, .noValidToken),
             (.internalError, .internalError),
             (.loginRequired, .loginRequired),
             (.internalServerError, .internalServerError):
            return true
        case let (.httpError(lhsCode, _), .httpError(rhsCode, _)):
            return lhsCode == rhsCode
        case let (.networkError(lhsError), .networkError(rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
