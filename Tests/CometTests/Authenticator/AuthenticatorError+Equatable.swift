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
             (.loginRequired, .loginRequired):
            return true
        case let (.clientError(lhsHttpError), .clientError(rhsHttpError)):
            return lhsHttpError == rhsHttpError
        case let (.serverError(lhsHttpError), .serverError(rhsHttpError)):
            return lhsHttpError == rhsHttpError
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
