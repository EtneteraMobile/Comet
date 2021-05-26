//
//  CometRequestResponseHandler.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
import Foundation

// TODO: documentation
public final class CometRequestResponseHandler: RequestResponseHandling {
    public init() {}

    public func handleResponse<ResponseObject: Decodable>(data: Data, response: URLResponse) -> AnyPublisher<ResponseObject, CometClientError> {
        guard let httpResponse = response as? HTTPURLResponse else {
            return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
        }

        switch httpResponse.statusCode {
        case 401:
            return Fail(error: CometClientError.unauthorized).eraseToAnyPublisher()
        case 403,
             404,
             405..<500:
            return Fail(error: CometClientError.httpError(code: httpResponse.statusCode)).eraseToAnyPublisher()
        case 500..<600:
            return Fail(error: CometClientError.internalServerError).eraseToAnyPublisher()
        default:
            return Just(data)
                .decode(type: ResponseObject.self, decoder: JSONDecoder())
                .mapError { CometClientError.parserError(reason: $0.localizedDescription) }
                .eraseToAnyPublisher()
        }
    }
}
