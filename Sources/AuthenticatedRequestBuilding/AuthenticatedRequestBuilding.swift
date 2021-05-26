//
//  AuthenticatedRequestBuilding.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Foundation

// TODO: documentation
public protocol AuthenticatedRequestBuilding {
    func authenticatedRequest(from request: URLRequest, with token: String) -> URLRequest
}
