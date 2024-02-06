import Foundation

/// A log formatter suitable for development which shows only the log level,
/// the file name and line together with the message.
public final class DevelopLogFormatter: LogFormatter {
	public init() {}

	public func formatEntry(_ entry: LogEntry) -> String {
		"\(stringForLogLevel(entry.level))\(stringForTags(entry.tags)) [\(entry.file.fileNameFromPath):\(entry.line)] - \(entry.message)"
	}

	private func stringForLogLevel(_ logLevel: LogLevel) -> String {
		switch logLevel {
		case .debug:
			"🔍"
		case .info:
			"💬"
		case .warn:
			"⚠️"
		case .error:
			"💣"
		case .fatal:
			"💥"
		}
	}

	private func stringForTags(_ tags: [LogTag]) -> String {
		tags.compactMap(\.abbreviation).joined()
	}
}
