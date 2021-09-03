//
//  File.swift
//  Comet
//
//  Created by Dominik Kohlman on 27.08.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

@testable import Comet
import Foundation

extension CometClientError: Equatable {
    public static func == (lhs: CometClientError, rhs: CometClientError) -> Bool {
        switch (lhs, rhs) {
        case (.internalError, .internalError),
             (.unauthorized, .unauthorized),
             (.loginRequired, .loginRequired),
             (.internalServerError, .internalServerError):
            return true
        case (.parserError(let lhsReason), .parserError(let rhsReason)):
                return lhsReason == rhsReason
        case (.networkError(let lhsUrlError), .networkError(let rhsUrlError)):
            return lhsUrlError == rhsUrlError

        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}
