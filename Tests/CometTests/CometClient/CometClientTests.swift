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

    func testIfCometClientErrorReturnsUnauthorizedWhenReceivesCode401() {
        let stubTokenProvider: TokenProviding = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.httpError(code: 401)).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )

        let sut = CometClient(
            tokenProvider: stubTokenProvider,
            authenticatedRequestBuilder: AuthenticatedRequestBuildingMock()
        )

        let exp = expectation(description: "")
        var receivedError: CometClientError?

        sut.performAuthenticatedRequest(URLRequest(url: URL(string: "wwww.someURL.com")!))
            .sink(
                receiveCompletion: { completion in
                    if case let Subscribers.Completion.failure(error) = completion {
                        receivedError = error
                        exp.fulfill()
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(receivedError, CometClientError.unauthorized)
    }
}
