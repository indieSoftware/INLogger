import INLogger
import XCTest

class LogLevelTests: XCTestCase {
	func testCaseOrder() {
		let expectedOrder = [LogLevel.debug, .info, .warn, .error, .fatal]
		let result = LogLevel.allCases
		XCTAssertEqual(expectedOrder, result)
	}

	func testSevereOrder() {
		XCTAssertTrue(LogLevel.debug == LogLevel.debug)
		XCTAssertTrue(LogLevel.debug < LogLevel.info)
		XCTAssertTrue(LogLevel.debug < LogLevel.warn)
		XCTAssertTrue(LogLevel.debug < LogLevel.error)
		XCTAssertTrue(LogLevel.debug < LogLevel.fatal)

		XCTAssertTrue(LogLevel.info > LogLevel.debug)
		XCTAssertTrue(LogLevel.info == LogLevel.info)
		XCTAssertTrue(LogLevel.info < LogLevel.warn)
		XCTAssertTrue(LogLevel.info < LogLevel.error)
		XCTAssertTrue(LogLevel.info < LogLevel.fatal)

		XCTAssertTrue(LogLevel.warn > LogLevel.debug)
		XCTAssertTrue(LogLevel.warn > LogLevel.info)
		XCTAssertTrue(LogLevel.warn == LogLevel.warn)
		XCTAssertTrue(LogLevel.warn < LogLevel.error)
		XCTAssertTrue(LogLevel.warn < LogLevel.fatal)

		XCTAssertTrue(LogLevel.error > LogLevel.debug)
		XCTAssertTrue(LogLevel.error > LogLevel.info)
		XCTAssertTrue(LogLevel.error > LogLevel.warn)
		XCTAssertTrue(LogLevel.error == LogLevel.error)
		XCTAssertTrue(LogLevel.error < LogLevel.fatal)

		XCTAssertTrue(LogLevel.fatal > LogLevel.debug)
		XCTAssertTrue(LogLevel.fatal > LogLevel.info)
		XCTAssertTrue(LogLevel.fatal > LogLevel.warn)
		XCTAssertTrue(LogLevel.fatal > LogLevel.error)
		XCTAssertTrue(LogLevel.fatal == LogLevel.fatal)
	}
}
