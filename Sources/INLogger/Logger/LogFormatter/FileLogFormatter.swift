import Foundation

/// A log formatter which prints more details about the log message than the `DevelopLogFormatter`.
public final class FileLogFormatter: LogFormatter {
	public init() {}

	public func formatEntry(_ entry: LogEntry) -> String {
		let formattedDateTime = dateFormatter.string(from: entry.date)
		return "\(formattedDateTime) \(stringForLogLevel(entry.level)) "
			+ "|\(stringForTags(entry.tags))| [\(entry.file.fileNameFromPath):\(entry.line)] \(entry.function)"
			+ " - \(entry.message)"
	}

	private func stringForLogLevel(_ logLevel: LogLevel) -> String {
		switch logLevel {
		case .debug:
			"D"
		case .info:
			"I"
		case .warn:
			"W"
		case .error:
			"E"
		case .fatal:
			"F"
		}
	}

	private func stringForTags(_ tags: [LogTag]) -> String {
		tags.map(\.name).joined(separator: "|")
	}

	private let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		// Just to be sure the date & time characters follow the same formatting independent
		// on the user device's settings we set the locale manually here.
		formatter.locale = Locale(identifier: "en_US_POSIX")
		// Keep the user's time zone.
		formatter.timeZone = .current
		// The format pattern can be found here: http://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
		formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
		return formatter
	}()
}
