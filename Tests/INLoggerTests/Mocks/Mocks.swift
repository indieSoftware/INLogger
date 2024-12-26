@testable import INLogger
import XCTest

class LogEntryCreatorMock: LogEntryCreator {
	var createEntryMock: (_ message: String, _ level: LogLevel, _ tags: [LogTag], _ file: String, _ function: String, _ line: Int32)
		-> LogEntry = { _, _, _, _, _, _ in
			XCTFail()
			return LogEntry(file: "", function: "", line: 0, message: "", level: .fatal, tags: [], date: Date(), additionalData: nil)
		}

	func createEntry(message: String, level: LogLevel, tags: [LogTag], file: String, function: String, line: Int32) -> LogEntry {
		createEntryMock(message, level, tags, file, function, line)
	}
}

final class LogFilterMock: LogFilter, Sendable {
	init(shouldEntryBeLoggedMock: @escaping @Sendable (_: LogEntry) -> Bool = { _ in
		XCTFail()
		return false
	}) {
		self.shouldEntryBeLoggedMock = shouldEntryBeLoggedMock
	}

	let shouldEntryBeLoggedMock: @Sendable (_ entry: LogEntry) -> Bool

	func shouldEntryBeLogged(_ entry: LogEntry) -> Bool {
		shouldEntryBeLoggedMock(entry)
	}
}

final class LogFormatterMock: LogFormatter, Sendable {
	init(formatEntryMock: @escaping @Sendable (_ entry: LogEntry) -> String = { _ in
		XCTFail()
		return ""
	}) {
		self.formatEntryMock = formatEntryMock
	}

	let formatEntryMock: @Sendable (_ entry: LogEntry) -> String

	func formatEntry(_ entry: LogEntry) -> String {
		formatEntryMock(entry)
	}
}

final class LogWriterMock: LogWriter, Sendable {
	init(writeMock: @escaping @Sendable (_ string: String) -> Void = { _ in
		XCTFail()
	}) {
		self.writeMock = writeMock
	}

	let writeMock: @Sendable (_ string: String) -> Void

	func write(_ string: String) {
		writeMock(string)
	}
}
