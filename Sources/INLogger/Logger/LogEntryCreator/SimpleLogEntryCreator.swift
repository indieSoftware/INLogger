import Foundation

/// A log creator which doesn't determines the thread number because it might take some time to process.
public class SimpleLogEntryCreator: LogEntryCreator {
	public init() {}

	// swiftlint:disable:next function_parameter_count
	public func createEntry(
		message: String,
		level: LogLevel,
		tags: [LogTag],
		file: String,
		function: String,
		line: Int32
	) -> LogEntry {
		LogEntry(
			file: file,
			function: function,
			line: Int(line),
			message: message,
			level: level,
			tags: tags,
			date: Date(), // The timestamp for this log message.
			additionalData: nil // No additional data necessary.
		)
	}
}
