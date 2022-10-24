@testable import INLogger
import XCTest

class DevelopLogFormatterTests: XCTestCase {
	private var formatter: DevelopLogFormatter!

	override func setUp() {
		formatter = DevelopLogFormatter()
	}

	func testLogEntryGetsFormattedCorrectly() throws {
		let message = "My logged message text"
		let date = Date(timeIntervalSince1970: 1_642_691_283) // 2022-01-20 15:08:03 GMT
		let logEntry = LogEntry(
			file: "/Application/075B57CD-339C-4EF5-9C1A-3CF47544347D/Documents/INLogger/LogFormatterTests.swift",
			function: "testLogEntryGetsFormattedCorrectly()",
			line: 25,
			message: message,
			level: .info,
			tags: [.general, .breadcrumb],
			date: date,
			additionalData: 3
		)

		let result = formatter.formatEntry(logEntry)

		// Note: date and time will change according to device/simulator timezone so we need to dynamically create it
		XCTAssertEqual(result, "💬⭐️🍞 [LogFormatterTests.swift:25] - My logged message text")
	}
}
