//
// Created by Milan Cap on 04.04.2023.
//

import Foundation

public struct CometClientHttpResponseError {
    public init(response: URLResponse, data: Data) {
        self.response = response
        self.data = data
    }

    public let response: URLResponse
    public let data: Data
}
