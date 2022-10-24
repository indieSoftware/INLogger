@testable import INLogger
import XCTest

class LoggerTests: XCTestCase {
	var logEntryCreator: SimpleLogEntryCreator!
	var logFilter: LogFilterMock!
	var logFormatter: LogFormatterMock!
	var logWriter: LogWriterMock!
	var pipeline: LogPipeline!
	var logger: Logger!

	override func setUp() {
		logEntryCreator = SimpleLogEntryCreator()
		logFilter = LogFilterMock()
		logFormatter = LogFormatterMock()
		logWriter = LogWriterMock()
		pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])
		logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline])
	}

	/// Modifies the log filter to return false which makes the pipeline to stop.
	/// Also injects a check into the filter which gets called with the passed log entry
	/// which can be used to ensures that the logged entry is correctly filled by the logger.
	private func injectLogEntryCheck(_ check: @escaping (_ entry: LogEntry) -> Void) {
		logFilter.shouldEntryBeLoggedMock = { entry in
			check(entry)
			// Prevent the pipeline to continue because we are not interested in the formatter or writer in these tests.
			return false
		}
	}

	func testDebugLog() throws {
		let message = "Debug Message"
		injectLogEntryCheck { entry in
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
		injectLogEntryCheck { entry in
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
		injectLogEntryCheck { entry in
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
		injectLogEntryCheck { entry in
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
		injectLogEntryCheck { entry in
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
		logFilter.shouldEntryBeLoggedMock = { _ in
			true
		}
		logFormatter.formatEntryMock = { _ in
			""
		}
		logWriter.writeMock = { _ in
			pipelineExpectation.fulfill()
		}
		logger.debug("Start")

		waitForExpectations(timeout: 1)

		// Block this thread until the logger's pipeline has really finished its work,
		// otherwise we might have a rare race-condition where the expectation in the writer
		// has been already fulfilled but the queue is still processing the writer.
		// That will then fail this test because the writer is still retained by the queue.
		logger.processingQueue.sync {}

		// Now test the retain cycle if there is anything kept in memory.
		weak var weakLogEntryCreator = logEntryCreator
		weak var weakLogFilter = logFilter
		weak var weakLogFormatter = logFormatter
		weak var weakLogWriter = logWriter
		weak var weakLogger = logger

		logEntryCreator = nil
		logFilter = nil
		logFormatter = nil
		logWriter = nil
		pipeline = nil
		logger = nil

		XCTAssertNil(weakLogEntryCreator)
		XCTAssertNil(weakLogger)
		XCTAssertNil(weakLogWriter)
		XCTAssertNil(weakLogFormatter)
		XCTAssertNil(weakLogFilter)
	}
}
