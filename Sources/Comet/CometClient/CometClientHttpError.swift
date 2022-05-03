//
// Created by Milan Cap on 12.01.2022.
//

import Foundation

public struct CometClientHttpError {
    public init(code: Int, data: Data) {
        self.code = code
        self.data = data
    }

    public let code: Int
    public let data: Data
}
