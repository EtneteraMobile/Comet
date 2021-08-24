//
//  CometRequestResponseHandler.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

/// TODO
public final class CometRequestResponseHandler: RequestResponseHandling {
    public init() {}

    /// TODO
    /// - Parameters:
    ///   - data: TODO
    ///   - response: TODO
    /// - Returns: TODO
    public func handleResponse(
        data: Data,
        response: URLResponse
    ) -> AnyPublisher<(data: Data, response: URLResponse), CometClientError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
        }

        switch httpResponse.statusCode {
        case 401:
            return Fail(error: CometClientError.unauthorized).eraseToAnyPublisher()
        case 400, 402..<500:
            let error = CometClientError.httpError(code: httpResponse.statusCode, data: data)
            return Fail(error: error).eraseToAnyPublisher()
        case 500..<600:
            return Fail(error: CometClientError.internalServerError).eraseToAnyPublisher()
        default:
            return Just((data: data, response: response)).setFailureType(to: CometClientError.self).eraseToAnyPublisher()
        }
    }
}
