//
//  CometClientError.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

// TODO: documentation
// TODO: add more cases that are important
public enum CometClientError: Error, LocalizedError {
    case unknown
    case unauthorized
    case loginRequired
    case apiError(reason: String)
    case parserError(reason: String)
    case networkError(from: URLError)
    case internalError

    public var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "Unauthorized error"
        case .loginRequired:
            return "Login required error"
        case .unknown:
            return "Unknown error"
        case .apiError(let reason):
            return reason
        case .parserError(let reason):
            return reason
        case .networkError(let error):
            return error.localizedDescription
        case .internalError:
            return "Internal error"
        }
    }
}
