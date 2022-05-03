//
//  DataTaskPublisher+Debug.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Combine
import Foundation

public extension URLSession.DataTaskPublisher {
    func debug(
        logLevel: RequestLogLevel,
        logger: @escaping (String) -> Void
    ) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { _ in
                guard logLevel.contains(.none) == false else {
                    return
                }

                if logLevel.contains(.url) {
                    logger(request.urlDebugDescription)
                }

                if
                    logLevel.contains(.headers),
                    let headers = request.headersDebugDescription
                {
                    logger(headers)
                }

                if
                    logLevel.contains(.body),
                    let body = request.bodyDebugDescription
                {
                    logger(body)
                }
            },
            receiveOutput: { data, response in
                if let response = response as? HTTPURLResponse {
                    if logLevel.contains(.url) {
                        logger(response.debugDescriptionString)
                    }

                    if
                        logLevel.contains(.headers),
                        !response.allHeaderFields.isEmpty
                    {
                        logger(LogDescribingStrings.headers.stringValue)

                        response.allHeaderFields.forEach {
                            logger("\($0.key): \($0.value)")
                        }
                    }
                }

                if
                    logLevel.contains(.body),
                    let prettyData = data.prettyPrintedJSON
                {
                    logger("\(LogDescribingStrings.body.stringValue)\n\(prettyData)")
                }
            }
        )
    }
}
