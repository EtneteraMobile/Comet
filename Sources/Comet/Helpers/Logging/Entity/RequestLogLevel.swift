//
//  RequestLogLevel.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

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
