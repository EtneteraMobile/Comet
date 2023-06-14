//
//  CometClientTests.swift
//  Comet
//
//  Created by Tuan Tu Do on 28.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
@testable import Comet
import XCTest

final class CometClientTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }
}
