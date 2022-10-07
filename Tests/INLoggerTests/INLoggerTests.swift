@testable import INLogger
import XCTest

class INLoggerTests: XCTestCase {
	func testVersionNumber() {
		let version = INLoggerVersion.version
		XCTAssertEqual(1, version)
	}
}
