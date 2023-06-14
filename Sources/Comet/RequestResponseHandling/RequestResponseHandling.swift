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
    func handleResponse<ResponseObject: Decodable>(data: Data, response: URLResponse) -> AnyPublisher<ResponseObject, CometClientError>
}
