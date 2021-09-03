//
//  AuthenticatedRequestBuildingMock.swift
//  Comet
//
//  Created by Dominik Kohlman on 27.08.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

@testable import Comet
import Foundation

final class AuthenticatedRequestBuildingMock: AuthenticatedRequestBuilding {

    func authenticatedRequest(from request: URLRequest, with token: String) -> URLRequest {
        request
    }
}
