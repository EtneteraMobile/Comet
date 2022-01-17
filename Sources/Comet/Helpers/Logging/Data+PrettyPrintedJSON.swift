//
//  Data+PrettyPrintedJSON.swift
//  Comet
//
//  Created by Jaroslav Novák on 17.01.2022.
//  Copyright © 2022 Etnetera. All rights reserved.
//

import Foundation

extension Data {
    var prettyPrintedJSON: String? {
        if
            let json = try? JSONSerialization.jsonObject(
                with: self,
                options: []
            ),
            let prettyData = try? JSONSerialization.data(
                withJSONObject: json,
                options: [.prettyPrinted]
            ),
            let prettyString = String(
                data: prettyData,
                encoding: .utf8
            )
        {
            return prettyString
        } else if let jsonString = String(
            data: self,
            encoding: .utf8
        ) {
            return jsonString
        } else {
            return nil
        }
    }
}
