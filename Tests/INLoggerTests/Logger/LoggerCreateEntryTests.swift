@testable import INLogger
import XCTest

@MainActor
class LoggerCreateEntryTests: XCTestCase, Sendable {
	var logEntryCreator: LogEntryCreatorMock!
	var logger: Logger!

	override func setUp() async throws {
		try await super.setUp()
		logEntryCreator = LogEntryCreatorMock()
		logger = Logger(entryCreator: logEntryCreator, pipelines: [])
	}

	func testCreateEntryParametersProvided() throws {
		let inputMessage = "Test message"
		let inputLevel = LogLevel.fatal
		let inputTags = [LogTag.unitTest]
		let inputFile = "Input file"
		let inputFunction = "Input function"
		let inputLine: Int32 = 543

		let outputEntry = LogEntry(file: "File", function: "Func", line: 33, message: "MessageText", level: .warn, tags: [], date: Date(), additionalData: nil)

		let entryCreatorExpectation = expectation(description: "entryCreatorExpectation")
		logEntryCreator.createEntryMock = { message, level, tags, file, function, line in
			XCTAssertEqual(message, inputMessage)
			XCTAssertEqual(level, inputLevel)
			XCTAssertEqual(tags, inputTags)
			XCTAssertEqual(file, inputFile)
			XCTAssertEqual(function, inputFunction)
			XCTAssertEqual(line, inputLine)
			entryCreatorExpectation.fulfill()
			return outputEntry
		}

		logger.log(message: inputMessage, level: inputLevel, tags: inputTags, file: inputFile, function: inputFunction, line: inputLine)

		waitForExpectations(timeout: 1)
	}

	func testEntryIsPassedToPipeline() throws {
		let inputMessage = "Test message"
		let inputLevel = LogLevel.fatal
		let inputTags = [LogTag.unitTest]
		let inputFile = "Input file"
		let inputFunction = "Input function"
		let inputLine: Int32 = 543

		let outputEntry = LogEntry(file: "File", function: "Func", line: 33, message: "MessageText", level: .warn, tags: [], date: Date(), additionalData: nil)

		let entryCreatorExpectation = expectation(description: "entryCreatorExpectation")
		logEntryCreator.createEntryMock = { _, _, _, _, _, _ in
			entryCreatorExpectation.fulfill()
			return outputEntry
		}

		let filterExpectation = expectation(description: "filterExpectation")
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { entry in
				XCTAssertEqual(entry, outputEntry)
				filterExpectation.fulfill()
				return false // Stop pipeline here
			}
		)

		let pipeline = LogPipeline(filter: logFilter, formatter: LogFormatterMock(), writer: [])
		logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline])

		logger.log(message: inputMessage, level: inputLevel, tags: inputTags, file: inputFile, function: inputFunction, line: inputLine)

		waitForExpectations(timeout: 1)
	}
}
