//
//  TokenProvidingError.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

// TODO: describe when to use each case
/// Describes errors in [TokenProviding](x-source-tag://TokenProviding) domain.
public enum TokenProvidingError: Error {
    case noToken
    case invalidToken
    case loginRequired
    case internalError
    case internalServerError
    case httpError(code: Int)
    case networkError(from: URLError)
}
