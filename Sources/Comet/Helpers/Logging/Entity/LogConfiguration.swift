//
//  LogConfiguration.swift
//  Comet
//
//  Created by Jaroslav Novák on 03.05.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

public struct LogConfiguration {
    let logLevel: RequestLogLevel
    let logger: (String) -> Void

    public init(
        logLevel: RequestLogLevel,
        logger: @escaping (String) -> Void
    ) {
        self.logLevel = logLevel
        self.logger = logger
    }
}
