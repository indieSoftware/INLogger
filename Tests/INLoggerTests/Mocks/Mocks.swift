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

final class LogFilterMock: LogFilter, @unchecked Sendable {
	var shouldEntryBeLoggedMock: (_ entry: LogEntry) -> Bool = { _ in
		XCTFail()
		return false
	}

	func shouldEntryBeLogged(_ entry: LogEntry) -> Bool {
		shouldEntryBeLoggedMock(entry)
	}
}

final class LogFormatterMock: LogFormatter, @unchecked Sendable {
	var formatEntryMock: (_ entry: LogEntry) -> String = { _ in
		XCTFail()
		return ""
	}

	func formatEntry(_ entry: LogEntry) -> String {
		formatEntryMock(entry)
	}
}

final class LogWriterMock: LogWriter, @unchecked Sendable {
	var writeMock: (_ string: String) -> Void = { _ in
		XCTFail()
	}

	func write(_ string: String) {
		writeMock(string)
	}
}
