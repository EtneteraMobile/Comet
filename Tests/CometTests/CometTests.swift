import XCTest
@testable import Comet

final class CometTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(Comet().text, "Hello, World!")
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}
