//
//  URLRequest+UrlDebugDescription.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

extension URLRequest {
    var urlDebugDescription: String {
        var debugString = "\(LogDescribingStrings.request.stringValue) "

        if let method = httpMethod {
            debugString += "\(method) "
        }

        if let urlString = url?.absoluteString {
            debugString += urlString
        }

        return debugString
    }

    var headersDebugDescription: String? {
        let headers = allHTTPHeaderFields ?? [:]
        if !headers.isEmpty {
            var debugString = LogDescribingStrings.headers.stringValue
            for (key, value) in headers {
                debugString += "\n\(key): \(value)"
            }
            return debugString
        }

        return nil
    }

    var bodyDebugDescription: String? {
        if
            let data = httpBody,
            let prettyData = data.prettyPrintedJSON
        {
            return "\(LogDescribingStrings.body.stringValue)\n\(prettyData)"
        }

        return nil
    }
}
