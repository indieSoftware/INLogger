@testable import INLogger
import XCTest

class LogPipelineProcessEntryTests: XCTestCase {
	var logFilter: LogFilterMock!
	var logFormatter: LogFormatterMock!
	var logWriter: LogWriterMock!

	let logEntry = LogEntry(file: "MyFile", function: "MyFunction", line: 42, message: "My message", level: .info, tags: [], date: Date(), additionalData: nil)

	override func setUp() {
		logFilter = LogFilterMock()
		logFormatter = LogFormatterMock()
		logWriter = LogWriterMock()
	}

	func testPipelineCallsAllComponents() throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		logFilter.shouldEntryBeLoggedMock = { entry in
			XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
			logFilterExpectation.fulfill()
			return true
		}

		let formattedString = "My formatted string"
		let logFormatterExpectation = expectation(description: "logFormatterExpectation")
		logFormatter.formatEntryMock = { entry in
			XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
			logFormatterExpectation.fulfill()
			return formattedString
		}

		let logWriterExpectation = expectation(description: "logWriterExpectation")
		logWriter.writeMock = { string in
			XCTAssertEqual(string, formattedString, "String has been changed by the pipeline")
			logWriterExpectation.fulfill()
		}

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])

		pipeline.processEntry(logEntry)

		waitForExpectations(timeout: 1)
	}

	func testPipelineStopsWhenFilterReturnsFalse() throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		logFilter.shouldEntryBeLoggedMock = { entry in
			XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
			logFilterExpectation.fulfill()
			return false
		}

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])

		pipeline.processEntry(logEntry)

		waitForExpectations(timeout: 1)
	}

	func testPipelineCallsMultipleWritersInTheirOrder() throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		logFilter.shouldEntryBeLoggedMock = { _ in
			logFilterExpectation.fulfill()
			return true
		}

		let formattedString = "My formatted string"
		let logFormatterExpectation = expectation(description: "logFormatterExpectation")
		logFormatter.formatEntryMock = { _ in
			logFormatterExpectation.fulfill()
			return formattedString
		}

		var logWriterHasBeenCalled = false
		var logWriter2HasBeenCalled = false
		let logWriterExpectation = expectation(description: "logWriterExpectation")
		logWriter.writeMock = { _ in
			XCTAssertFalse(logWriterHasBeenCalled)
			XCTAssertFalse(logWriter2HasBeenCalled)
			logWriterHasBeenCalled = true
			logWriterExpectation.fulfill()
		}

		let logWriter2Expectation = expectation(description: "logWriter2Expectation")
		let logWriter2 = LogWriterMock()
		logWriter2.writeMock = { _ in
			XCTAssertTrue(logWriterHasBeenCalled)
			XCTAssertFalse(logWriter2HasBeenCalled)
			logWriter2HasBeenCalled = true
			logWriter2Expectation.fulfill()
		}

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter, logWriter2])

		pipeline.processEntry(logEntry)

		waitForExpectations(timeout: 1)

		XCTAssertTrue(logWriterHasBeenCalled)
		XCTAssertTrue(logWriter2HasBeenCalled)
	}
}
