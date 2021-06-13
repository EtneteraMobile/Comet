//
//  CometClientError.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

/// TODO
public enum CometClientError: Error {
    case internalError
    case unauthorized
    case loginRequired
    case parserError(reason: String)
    case networkError(from: URLError)
    case httpError(code: Int)
    case internalServerError
}
