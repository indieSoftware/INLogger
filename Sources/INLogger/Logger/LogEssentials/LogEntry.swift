import Foundation

/// A log message wrapped in a struct to make it easier
/// to pass its data through different pipeline steps.
public struct LogEntry: Sendable {
	/// The file's name where the log has been called.
	public let file: String
	/// The function's name of the log call.
	public let function: String
	/// The line within the function of the log call.
	public let line: Int
	/// The log's message text as a plain text.
	public let message: String
	/// A log level indicating the severity of the message.
	public let level: LogLevel
	/// The log tags associated to that log message.
	public let tags: [LogTag]
	/// The date and time when this log was created.
	public let date: Date
	/// Any additional information can be passed here.
	public let additionalData: Sendable?
}

extension LogEntry: Equatable {
	public static func == (lhs: LogEntry, rhs: LogEntry) -> Bool {
		if lhs.file != rhs.file { return false }
		if lhs.function != rhs.function { return false }
		if lhs.line != rhs.line { return false }
		if lhs.level != rhs.level { return false }
		if lhs.tags != rhs.tags { return false }
		if lhs.date != rhs.date { return false }
		if lhs.message != rhs.message { return false }
		return true
	}
}
