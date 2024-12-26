@testable import INLogger
import XCTest

@MainActor
class LoggerTests: XCTestCase, Sendable {
	/// Creates a logger with the injected check for the LogFilterMock.
	/// Modifies the log filter to return false which makes the pipeline to stop.
	/// Also injects a check into the filter which gets called with the passed log entry
	/// which can be used to ensures that the logged entry is correctly filled by the logger.
	private func makeLogger(_ check: @escaping @Sendable (_ entry: LogEntry) -> Void) -> Logger {
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { entry in
				check(entry)
				// Prevent the pipeline to continue because we are not interested in the formatter or writer in these tests.
				return false
			}
		)
		let logEntryCreator = SimpleLogEntryCreator()
		let logFormatter = LogFormatterMock()
		let logWriter = LogWriterMock()
		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])
		let logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline])
		return logger
	}

	func testDebugLog() throws {
		let message = "Debug Message"
		let logger = makeLogger { entry in
			XCTAssertTrue(entry.file.hasSuffix("LoggerTests.swift"))
			XCTAssertEqual(entry.function, "testDebugLog()")
			XCTAssertEqual(entry.line, 1)
			XCTAssertEqual(entry.level, .debug)
			XCTAssertEqual(entry.tags, [.unitTest])
			XCTAssertEqual(entry.message, message)
			XCTAssertNil(entry.additionalData)
		}

		logger.debug(message, tag: .unitTest, line: 1)
		logger.debug(message, tags: [.unitTest], line: 1)
	}

	func testInfoLog() {
		let message = "Info Message"
		let logger = makeLogger { entry in
			XCTAssertTrue(entry.file.hasSuffix("LoggerTests.swift"))
			XCTAssertEqual(entry.function, "testInfoLog()")
			XCTAssertEqual(entry.line, 2)
			XCTAssertEqual(entry.level, .info)
			XCTAssertEqual(entry.tags, [.unitTest])
			XCTAssertEqual(entry.message, message)
			XCTAssertNil(entry.additionalData)
		}

		logger.info(message, tag: .unitTest, line: 2)
		logger.info(message, tags: [.unitTest], line: 2)
	}

	func testWarnLog() {
		let message = "Warn Message"
		let logger = makeLogger { entry in
			XCTAssertTrue(entry.file.hasSuffix("LoggerTests.swift"))
			XCTAssertEqual(entry.function, "testWarnLog()")
			XCTAssertEqual(entry.line, 3)
			XCTAssertEqual(entry.level, .warn)
			XCTAssertEqual(entry.tags, [.unitTest])
			XCTAssertEqual(entry.message, message)
			XCTAssertNil(entry.additionalData)
		}

		logger.warn(message, tag: .unitTest, line: 3)
		logger.warn(message, tags: [.unitTest], line: 3)
	}

	func testErrorLog() {
		let message = "Error Message"
		let logger = makeLogger { entry in
			XCTAssertTrue(entry.file.hasSuffix("LoggerTests.swift"))
			XCTAssertEqual(entry.function, "testErrorLog()")
			XCTAssertEqual(entry.line, 4)
			XCTAssertEqual(entry.level, .error)
			XCTAssertEqual(entry.tags, [.unitTest])
			XCTAssertEqual(entry.message, message)
			XCTAssertNil(entry.additionalData)
		}

		logger.error(message, tag: .unitTest, line: 4)
		logger.error(message, tags: [.unitTest], line: 4)
	}

	func testFatalLog() {
		let message = "Fatal Message"
		let logger = makeLogger { entry in
			XCTAssertTrue(entry.file.hasSuffix("LoggerTests.swift"))
			XCTAssertEqual(entry.function, "testFatalLog()")
			XCTAssertEqual(entry.line, 5)
			XCTAssertEqual(entry.level, .fatal)
			XCTAssertEqual(entry.tags, [.unitTest])
			XCTAssertEqual(entry.message, message)
			XCTAssertNil(entry.additionalData)
		}

		logger.fatal(message, tag: .unitTest, line: 5)
		logger.fatal(message, tags: [.unitTest], line: 5)
	}

	func testLoggerHasNoRetainCycle() {
		// Make the components pass to ensure the pipeline components are fully resolved and retained.
		let pipelineExpectation = expectation(description: "pipelineExpectation")
		let logFilter = LogFilterMock(
			shouldEntryBeLoggedMock: { _ in
				true
			}
		)
		let logFormatter = LogFormatterMock(
			formatEntryMock: { _ in
				""
			}
		)
		let logWriter = LogWriterMock(
			writeMock: { _ in
				pipelineExpectation.fulfill()
			}
		)

		let logEntryCreator = SimpleLogEntryCreator()
		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])
		let logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline])

		logger.debug("Start")

		waitForExpectations(timeout: 1)

		// Block this thread until the logger's pipeline has really finished its work,
		// otherwise we might have a rare race-condition where the expectation in the writer
		// has been already fulfilled but the queue is still processing the writer.
		// That will then fail this test because the writer is still retained by the queue.
		logger.processingQueue.sync {}

		// Now test the retain cycle if there is anything kept in memory.
		func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
			addTeardownBlock { [weak object] in
				XCTAssertNil(
					object,
					"Potential memory leak detected. Instance should have been deallocated.",
					file: file,
					line: line
				)
			}
		}

		trackForMemoryLeaks(logEntryCreator)
		trackForMemoryLeaks(logFilter)
		trackForMemoryLeaks(logFormatter)
		trackForMemoryLeaks(logWriter)
		trackForMemoryLeaks(logger)
	}
}
