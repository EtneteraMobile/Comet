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

final class AuthenticatorTests: XCTestCase {
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    func testAccessTokenReturnsToken() {
        let token = "token"
        let tokenProvider = StubTokenProvider(
            accessToken: Just(token)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.accessToken
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

    func testNoValidTokenErrorIsReturnedWhenTokenProviderReturnsNoTokenError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.noToken).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

    func testNoValidTokenErrorIsReturnedWhenTokenProviderReturnsInvalidTokenError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.invalidToken).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

    func testLoginRequiredErrorIsReturnedWhenTokenProviderReturnsLoginRequiredError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.loginRequired).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.loginRequired)
    }

    func testInternalServerErrorIsReturnedWhenTokenProviderReturnsInternalServerError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.internalServerError).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.internalServerError)
    }

    func testHttpErrorIsReturnedWhenTokenProviderReturnsHttpError() {
        let code = 400
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.httpError(code: code)).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.httpError(code: code))
    }

    func testInternalErrorIsReturnedWhenTokenProviderReturnsInternalError() {
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.internalError).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.internalError)
    }

    func testNetworkErrorIsReturnedWhenTokenProviderReturnsNetworkError() {
        let urlError = URLError(.badServerResponse)
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.networkError(from: urlError)).eraseToAnyPublisher(),
            refreshAccessToken: Empty().eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedError: AuthenticatorError?

        sut.accessToken
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

        XCTAssertEqual(receivedError, AuthenticatorError.networkError(from: urlError))
    }

    func testAccessTokenReturnsRefreshedAccessToken() {
        let token = "token"
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(token)
                .delay(for: 2, scheduler: RunLoop.main)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.refreshAccessToken
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &cancellables)

        sut.accessToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { token in
                    receivedToken = token
                    exp.fulfill()
                }
            )
            .store(in: &cancellables)

        waitForExpectations(timeout: 3)

        XCTAssertEqual(token, receivedToken)
    }

    func testRefreshAccessTokenReturnsToken() {
        let token = "token"
        let tokenProvider = StubTokenProvider(
            accessToken: Empty().eraseToAnyPublisher(),
            refreshAccessToken: Just(token)
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        let exp = expectation(description: "")
        var receivedToken: String?

        sut.refreshAccessToken
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
        sut.refreshAccessToken
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
        sut.accessToken
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
        sut.refreshAccessToken
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
        sut.refreshAccessToken
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
        sut.refreshAccessToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    exp1.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp2 = XCTestExpectation()
        sut.accessToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in
                    exp2.fulfill()
                }
            )
            .store(in: &cancellables)

        let exp3 = XCTestExpectation()
        sut.refreshAccessToken
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

    // The refresh token publisher is returned when requesting access token,
    // because the access token is being refreshed.
    // Before a new subscription is created, the publisher emits a new access token
    // and the subscriber can miss the emited value and completes without a value.
    // We are using shareReplay operator to prevent this.
    func testAccessTokenIsReceivedWhenSubscribingLate() {
        let token = "token"
        let tokenProvider = StubTokenProvider(
            accessToken: Fail(error: TokenProvidingError.internalError).eraseToAnyPublisher(),
            refreshAccessToken: Just(token)
                .delay(for: 0.001, scheduler: DispatchQueue.global())
                .setFailureType(to: TokenProvidingError.self)
                .eraseToAnyPublisher()
        )
        let sut = Authenticator(tokenProvider: tokenProvider)

        sut.refreshAccessToken
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { _ in print("token refreshed") }
            )
            .store(in: &cancellables)

        var receivedRefreshToken = [Int]()
        var finishedRefreshedToken = [Int]()
        var failed = [Int]() // these get the access token, which is now a Fail

        for i in 0...999 {
            let exp = expectation(description: "\(i)")
            sut.accessToken
                .receive(on: DispatchQueue.main) // synchronizing the access to the arrays
                .sink(
                    receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            finishedRefreshedToken.append(i)
                        case .failure:
                            failed.append(i)
                        }
                        exp.fulfill()
                    },
                    receiveValue: { token in
                        receivedRefreshToken.append(i)
                    }
                )
                .store(in: &cancellables)
        }

        waitForExpectations(timeout: 2)

        receivedRefreshToken.sort()
        finishedRefreshedToken.sort()
        failed.sort()

        XCTAssertEqual(receivedRefreshToken, finishedRefreshedToken)
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
        case (.networkError(let lhsError), .networkError(let rhsError)):
            return lhsError == rhsError
        default:
            return false
        }
    }
}
