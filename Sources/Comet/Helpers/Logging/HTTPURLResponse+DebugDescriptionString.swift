//
//  HTTPURLResponse+DebugDescriptionString.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

extension HTTPURLResponse {

    var statusCodeIcon: String {
        switch statusCode {
        case 100...199:
            return LogDescribingStrings.informationalStatus.stringValue
        case 200...299:
            return LogDescribingStrings.successfulStatus.stringValue
        case 300...399:
            return LogDescribingStrings.redirectionStatus.stringValue
        case 400...499:
            return LogDescribingStrings.clientErrorStatus.stringValue
        case 500...599:
            return LogDescribingStrings.serverErrorStatus.stringValue
        default:
            return ""
        }
    }

    var debugDescriptionString: String {
        "\(LogDescribingStrings.response.stringValue) \(url?.absoluteString ?? "") [\(statusCode) \(statusCodeIcon)]"
    }
}
