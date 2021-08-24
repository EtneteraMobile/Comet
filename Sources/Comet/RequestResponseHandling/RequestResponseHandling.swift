//
//  RequestResponseHandling.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

/// TODO
public protocol RequestResponseHandling {
    /// TODO
    /// - Parameters:
    ///   - data: TODO
    ///   - response: TODO
    func handleResponse(
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError>
}
