import XCTest
@testable import LayoutKit

class LayoutKitTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        XCTAssertEqual(LayoutKit().text, "Hello, World!")
    }


    static var allTests : [(String, (LayoutKitTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
