import Foundation

/// A release log filter which filters out all `debug` logs,
/// but keeps all other log levels regardless of any tag's state.
public final class ReleaseLogFilter: LogFilter {
	public init() {}

	public func shouldEntryBeLogged(_ entry: LogEntry) -> Bool {
		switch entry.level {
		case .debug:
			// Never log debug statements.
			false
		case .info, .warn, .error, .fatal:
			// Always log non-debug statements and ignore any tag states.
			true
		}
	}
}
