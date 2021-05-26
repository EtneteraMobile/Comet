//
//  AuthenticatorTests.swift
//  Comet
//
//  Created by Tuan Tu Do on 26.05.2021.
//  Copyright © 2021 Etnetera. All rights reserved.
//

import Combine
@testable import Comet
import XCTest

// TODO: rename tests
class AuthenticatorTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testReceivingTokenIsSuccessful() {
        let token = "thisIsJustRandomToken"
        let tokenProvider = StubTokenProvider(
            accessToken: Just(token)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.token
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    receivedToken = token
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(token, receivedToken)
    }

    func testTokenReturnsNoValidTokenError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.noToken).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.token
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

        XCTAssertEqual(receivedError, AuthenticatorError.noValidToken)
    }

    func testTokenReturnsRefreshedTokenAfterNewTokenIsRefreshed() {
        let refreshedToken = "thisIsJustRandomToken"
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(refreshedToken)
                .delay(for: 2, scheduler: RunLoop.main)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.refreshedToken
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        sut.token
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    receivedToken = token
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)

        XCTAssertEqual(refreshedToken, receivedToken)
    }

    func testRefreshedTokenReturnsSuccessfullyNewToken() {
        let refreshedToken = "tokentoken"
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(refreshedToken)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    receivedToken = token
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 1)

        XCTAssertEqual(refreshedToken, receivedToken)
    }

    func testRefreshedTokenReturnsNoValidTokenError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Fail(error: TokenProvidingError.noToken).eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.refreshedToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.noValidToken)
    }

    func testMultipleRequestsForTokenAndRefreshedTokenAtTheSameTime() {
        let refreshedToken = "token"
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(refreshedToken)
                .delay(for: 3, scheduler: RunLoop.main)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp1 = XCTestExpectation()
        var token1: String?
        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    token1 = token
                    exp1.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp2 = XCTestExpectation()
        var token2: String?
        sut.token
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    token2 = token
                    exp2.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp3 = XCTestExpectation()
        var token3: String?
        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    token3 = token
                    exp3.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp4 = XCTestExpectation()
        var token4: String?
        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    token4 = token
                    exp4.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [exp1, exp2, exp3, exp4], timeout: 4)

        XCTAssertEqual(refreshedToken, token1)
        XCTAssertEqual(refreshedToken, token2)
        XCTAssertEqual(refreshedToken, token3)
        XCTAssertEqual(refreshedToken, token4)
    }

    func testMultipleRequestsForTokenAndRefreshedTokenAtTheSameTimeCallsTokenProviderOnlyOnce() {
        let token = "token"
        var counter = 0
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(token)
                .setFailureType(to: TokenProvidingError.self)
                .delay(for: 2, scheduler: RunLoop.main)
                .handleEvents(receiveOutput: { _ in
                    counter += 1
                })
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp1 = XCTestExpectation()
        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    exp1.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp2 = XCTestExpectation()
        sut.token
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    exp2.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp3 = XCTestExpectation()
        sut.refreshedToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    exp3.fulfill()
                }
            )
            .store(in: &cancellables)

        wait(for: [exp1, exp2, exp3], timeout: 3)

        XCTAssertEqual(counter, 1)
    }
}

extension AuthenticatorError: Equatable {
    public static func == (lhs: AuthenticatorError, rhs: AuthenticatorError) -> Bool {
        switch (lhs, rhs) {
        case (.noValidToken, .noValidToken),
             (.internalError, .internalError),
             (.loginRequired, .loginRequired),
             (.internalServerError, .internalServerError):
            return true
        case (.httpError(let lhsCode), .httpError(let rhsCode)):
            return lhsCode == rhsCode
        default:
            return false
        }
    }
}

