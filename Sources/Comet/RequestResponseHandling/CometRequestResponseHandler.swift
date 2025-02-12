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

    public func handleResponse<ResponseObject: Decodable>(
        data: Data
    ) -> AnyPublisher<ResponseObject, CometClientError> {
		Just(data)
			.decode(type: ResponseObject.self, decoder: JSONDecoder())
            .mapError { CometClientError.parserError(reason: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

	public func handleHTTPResponse(data: Data, response: URLResponse) -> AnyPublisher<Data, CometClientError> {
		guard let httpResponse = response as? HTTPURLResponse else {
			return Fail(error: CometClientError.internalError).eraseToAnyPublisher()
		}

		switch httpResponse.statusCode {
		case 100..<400:
			return Just(data).setFailureType(to: CometClientError.self).eraseToAnyPublisher()
		case 401:
			let error = CometClientError.clientError(error: CometClientHttpError(code: httpResponse.statusCode, data: data))
			return Fail(error: error).eraseToAnyPublisher()
		case 402..<500:
			let error = CometClientError.clientError(error: CometClientHttpError(code: httpResponse.statusCode, data: data))
			return Fail(error: error).eraseToAnyPublisher()
		case 500..<600:
			let error = CometClientError.serverError(error: CometClientHttpError(code: httpResponse.statusCode, data: data))
			return Fail(error: error).eraseToAnyPublisher()
		default:
			let error = CometClientError.unknownError(error: CometClientHttpError(code: httpResponse.statusCode, data: data))
			return Fail(error: error).eraseToAnyPublisher()
		}
	}
}
