//
//  LogDescribingStrings.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

enum LogDescribingStrings {
    case headers
    case body
    case request
    case response
    case informationalStatus
    case successfulStatus
    case redirectionStatus
    case clientErrorStatus
    case serverErrorStatus
}

extension LogDescribingStrings {
    var stringValue: String {
        switch self {
        case .headers:
            return "----- HEADERS -----"
        case .body:
            return "------ BODY ------"
        case .request:
            return "⬆️"
        case .response:
            return "⬇️"
        case .informationalStatus:
            return "ℹ️"
        case .successfulStatus:
            return "✅"
        case .redirectionStatus:
            return "↪️"
        case .clientErrorStatus:
            return "⚠️"
        case .serverErrorStatus:
            return "❌"
        }
    }
}
