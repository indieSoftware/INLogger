@testable import INLogger
import XCTest

class SimpleLogFormatterTests: XCTestCase {
	private var formatter: SimpleLogFormatter!

	override func setUp() {
		formatter = SimpleLogFormatter()
	}

	func testLogEntryGetsFormattedCorrectly() throws {
		let message = "My logged message text"
		let date = Date(timeIntervalSince1970: 1_642_691_283) // 2022-01-20 15:08:03 GMT
		let logEntry = LogEntry(
			file: "/Application/075B57CD-339C-4EF5-9C1A-3CF47544347D/Documents/SimpleLogFormatterTests.swift",
			function: "testLogEntryGetsFormattedCorrectly()",
			line: 25,
			message: message,
			level: .info,
			tags: [.breadcrumb, .general],
			date: date,
			additionalData: 3
		)

		let result = formatter.formatEntry(logEntry)

		XCTAssertEqual(message, result)
	}
}
