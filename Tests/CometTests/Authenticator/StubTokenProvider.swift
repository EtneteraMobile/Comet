//
//  StubTokenProvider.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
@testable import Comet
import Foundation

final class StubTokenProvider: TokenProviding {
    let accessToken: AnyPublisher<String, TokenProvidingError>
    let refreshAccessToken: AnyPublisher<String, TokenProvidingError>

    init(accessToken: AnyPublisher<String, TokenProvidingError>, refreshAccessToken: AnyPublisher<String, TokenProvidingError>) {
        self.accessToken = accessToken
        self.refreshAccessToken = refreshAccessToken
    }
}
