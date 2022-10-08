@testable import INLogger
import XCTest

class DevelopmentLogFilterTests: XCTestCase {
	private var filter: DevelopmentLogFilter!
	private let disabledTag = LogTag(state: .disabled, name: "DisabledTag", abbreviation: "🐞")
	private let enabledTag = LogTag(state: .enabled, name: "EnabledTag", abbreviation: "🐞")
	private let forceDisabledTag = LogTag(state: .forceDisabled, name: "ForceDisabledTag", abbreviation: "🐞")

	override func setUpWithError() throws {
		filter = DevelopmentLogFilter()
	}

	// MARK: - Debug level tests

	func testDebugMessagesWithoutTagsShouldBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testDebugMessagesWithDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testDebugMessagesWithEnabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testDebugMessagesWithDisabledAndEnabledTagsShouldBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag, enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testDebugMessagesWithForceDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testDebugMessagesWithForceDisabledAndEnabledTagsShouldNotBeLogged() throws {
		let logLevel = LogLevel.debug
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag, forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	// MARK: - Info level tests

	func testInfoMessagesWithoutTagsShouldBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testInfoMessagesWithDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testInfoMessagesWithEnabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testInfoMessagesWithDisabledAndEnabledTagsShouldBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag, enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testInfoMessagesWithForceDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testInfoMessagesWithForceDisabledAndEnabledTagsShouldNotBeLogged() throws {
		let logLevel = LogLevel.info
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag, forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	// MARK: - Warn level tests

	func testWarnMessagesWithoutTagsShouldBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testWarnMessagesWithDisabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testWarnMessagesWithEnabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testWarnMessagesWithDisabledAndEnabledTagsShouldBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag, enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testWarnMessagesWithForceDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testWarnMessagesWithForceDisabledAndEnabledTagsShouldNotBeLogged() throws {
		let logLevel = LogLevel.warn
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag, forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	// MARK: - Error level tests

	func testErrorMessagesWithoutTagsShouldBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testErrorMessagesWithDisabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testErrorMessagesWithEnabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testErrorMessagesWithDisabledAndEnabledTagsShouldBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag, enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testErrorMessagesWithForceDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testErrorMessagesWithForceDisabledAndEnabledTagsShouldNotBeLogged() throws {
		let logLevel = LogLevel.error
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag, forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	// MARK: - Fatal level tests

	func testFatalMessagesWithoutTagsShouldBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testFatalMessagesWithDisabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testFatalMessagesWithEnabledTagShouldBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testFatalMessagesWithDisabledAndEnabledTagsShouldBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [disabledTag, enabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertTrue(result)
	}

	func testFatalMessagesWithForceDisabledTagShouldNotBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}

	func testFatalMessagesWithForceDisabledAndEnabledTagsShouldNotBeLogged() throws {
		let logLevel = LogLevel.fatal
		let logEntry = LogEntry(
			file: "MyFile",
			function: "MyFunction",
			line: 42,
			message: "No message",
			level: logLevel,
			tags: [enabledTag, forceDisabledTag],
			date: Date(),
			additionalData: nil
		)

		let result = filter.shouldEntryBeLogged(logEntry)

		XCTAssertFalse(result)
	}
}
