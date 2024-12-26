@testable import INLogger
import XCTest

@MainActor
class LogPipelineProcessEntryTests: XCTestCase, Sendable {
	let logEntry = LogEntry(file: "MyFile", function: "MyFunction", line: 42, message: "My message", level: .info, tags: [], date: Date(), additionalData: nil)

	func testPipelineCallsAllComponents() throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { entry in
				XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
				logFilterExpectation.fulfill()
				return true
			}
		)

		let formattedString = "My formatted string"
		let logFormatterExpectation = expectation(description: "logFormatterExpectation")
		let logFormatter = LogFormatterMock(
			formatEntryMock: { entry in
				XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
				logFormatterExpectation.fulfill()
				return formattedString
			}
		)

		let logWriterExpectation = expectation(description: "logWriterExpectation")
		let logWriter = LogWriterMock(
			writeMock: { string in
				XCTAssertEqual(string, formattedString, "String has been changed by the pipeline")
				logWriterExpectation.fulfill()
			}
		)

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])

		pipeline.processEntry(logEntry)

		waitForExpectations(timeout: 1)
	}

	func testPipelineStopsWhenFilterReturnsFalse() throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { entry in
				XCTAssertEqual(entry, self.logEntry, "Log entry has been changed by the pipeline")
				logFilterExpectation.fulfill()
				return false
			}
		)

		let logFormatter = LogFormatterMock()
		let logWriter = LogWriterMock()
		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])

		pipeline.processEntry(logEntry)

		waitForExpectations(timeout: 1)
	}

	func testPipelineCallsMultipleWritersInTheirOrder() async throws {
		let logFilterExpectation = expectation(description: "logFilterExpectation")
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { _ in
				logFilterExpectation.fulfill()
				return true
			}
		)

		let formattedString = "My formatted string"
		let logFormatterExpectation = expectation(description: "logFormatterExpectation")
		let logFormatter = LogFormatterMock(
			formatEntryMock: { _ in
				logFormatterExpectation.fulfill()
				return formattedString
			}
		)

		actor LogWriterState {
			var logWriterHasBeenCalled = false
			var logWriter2HasBeenCalled = false

			func setLogWriterHasBeenCalled() -> Bool {
				guard !logWriterHasBeenCalled, !logWriter2HasBeenCalled else { return false }
				logWriterHasBeenCalled = true
				return true
			}

			func setLogWriter2HasBeenCalled() -> Bool {
				guard logWriterHasBeenCalled, !logWriter2HasBeenCalled else { return false }
				logWriter2HasBeenCalled = true
				return true
			}
		}
		let logWriterState = LogWriterState()

		let logWriterExpectation = expectation(description: "logWriterExpectation")
		let logWriter = LogWriterMock(
			writeMock: { _ in
				Task { @MainActor in
					let result = await logWriterState.setLogWriterHasBeenCalled()
					XCTAssertTrue(result)
					logWriterExpectation.fulfill()
				}
			}
		)

		let logWriter2Expectation = expectation(description: "logWriter2Expectation")
		let logWriter2 = LogWriterMock(
			writeMock: { _ in
				Task { @MainActor in
					let result = await logWriterState.setLogWriter2HasBeenCalled()
					XCTAssertTrue(result)
					logWriter2Expectation.fulfill()
				}
			}
		)

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter, logWriter2])

		pipeline.processEntry(logEntry)

		await fulfillment(
			of: [
				logFilterExpectation,
				logFormatterExpectation,
				logWriterExpectation,
				logWriter2Expectation
			],
			timeout: 1
		)

		let logWriterHasBeenCalled = await logWriterState.logWriterHasBeenCalled
		XCTAssertTrue(logWriterHasBeenCalled)
		let logWriter2HasBeenCalled = await logWriterState.logWriter2HasBeenCalled
		XCTAssertTrue(logWriter2HasBeenCalled)
	}
}
