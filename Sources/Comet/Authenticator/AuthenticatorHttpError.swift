//
// Created by Milan Cap on 12.01.2022.
//

import Foundation

struct AuthenticatorHttpError: Equatable {
    let code: Int
    let data: Data
}
