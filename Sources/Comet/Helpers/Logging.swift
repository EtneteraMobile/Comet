//
//  Network.swift
//  Direct
//
//  Created by Lukáš Hromadník on 30.07.2021.
//  Copyright © 2021 Etnetera a.s. All rights reserved.
//

import Combine
import Foundation

extension Data {
    var prettyPrintedJSON: String {
        if
            let json = try? JSONSerialization.jsonObject(with: self, options: []),
            let prettyData = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted]),
            let prettyString = String(data: prettyData, encoding: .utf8)
        {
            return prettyString
        } else if let jsonString = String(data: self, encoding: .utf8) {
            return jsonString
        }

        return ""
    }
}

public struct RequestLogLevel: OptionSet {
    public let rawValue: UInt8

    public init(rawValue: UInt8) {
        self.rawValue = rawValue
    }

    public static let none: RequestLogLevel = []
    public static let url = RequestLogLevel(rawValue: 1)
    public static let headers = RequestLogLevel(rawValue: 0b11)
    public static let body = RequestLogLevel(rawValue: 0b101)
    public static let full: RequestLogLevel = [.url, .headers, .body]
}

public extension URLSession.DataTaskPublisher {
    func debug(logLevel: RequestLogLevel) -> Publishers.HandleEvents<Self> {
        handleEvents(
            receiveSubscription: { _ in
                if logLevel.contains(.url) {
                    Swift.print(request.urlDebugDescription)
                }

                if logLevel.contains(.headers), let headers = request.headersDebugDescription {
                    Swift.print(headers)
                }

                if logLevel.contains(.body), let body = request.bodyDebugDescription {
                    Swift.print(body)
                }
            },
            receiveOutput: { data, response in
                if let response = response as? HTTPURLResponse {
                    if logLevel.contains(.url) {
                        Swift.print(response.debugDescription)
                    }

                    if logLevel.contains(.headers) {
                        if !response.allHeaderFields.isEmpty {
                            Swift.print("----- HEADERS -----")
                            response.allHeaderFields.forEach {
                                Swift.print("\($0.key): \($0.value)")
                            }
                        }
                    }
                }

                if logLevel.contains(.body) {
                    let prettyData = data.prettyPrintedJSON
                    if !prettyData.isEmpty {
                        Swift.print("----- BODY -----")
                        Swift.print(data.prettyPrintedJSON)
                    }
                }
            }
        )
    }
}

extension URLRequest {
    var urlDebugDescription: String {
        var debugString = "⬆️ "

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
            var debugString = "----- HEADERS -----"
            for (key, value) in headers {
                debugString += "\n\(key): \(value)"
            }
            return debugString
        }

        return nil
    }

    var bodyDebugDescription: String? {
        if let data = httpBody {
            return "----- BODY -----\n\(data.prettyPrintedJSON)"
        }

        return nil
    }
}

extension HTTPURLResponse {
    // swiftlint:disable switch_case_on_newline
    var statusCodeIcon: String {
        switch statusCode {
        case 100...199: return "ℹ️"
        case 200...299: return "✅"
        case 300...399: return "↪️"
        case 400...499: return "⚠️"
        case 500...599: return "❌"
        default: return ""
        }
    }
    // swiftlint:enable switch_case_on_newline

    // swiftlint:disable:next override_in_extension
    open override var debugDescription: String {
        "⬇️ \(url?.absoluteString ?? "") [\(statusCode) \(statusCodeIcon)]"
    }
}
