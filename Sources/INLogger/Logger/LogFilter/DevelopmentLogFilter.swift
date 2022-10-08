import Foundation

/// A typical development log filter which doesn't filter out anything,
/// so even 'debug' logs get logged.
/// However, the log tag's state is respected which means when at least
/// one tag is `forceDisabled` then it won't be logged regardless
/// of the log's level.
/// When all tags are `disabled` then `debug` and `info` logs
/// also won't be logged.
public final class DevelopmentLogFilter: LogFilter {
	public init() {}

	public func shouldEntryBeLogged(_ entry: LogEntry) -> Bool {
		let tagPriority = entry.tags.highestPriorityLogTagState
		guard tagPriority != .forceDisabled else {
			// Ignore log statements regardless of the log level
			// when at least one tag has the `forceDisabled` state.
			return false
		}

		switch entry.level {
		case .debug, .info:
			// Only log debug and info logs when at least one tag is enabled.
			return tagPriority == .enabled
		case .warn, .error, .fatal:
			// Non-debug logs should always be logged regardless of the tag's state.
			return true
		}
	}
}
