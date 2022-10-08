import Foundation

/// A simple log formatter which only passes the message to the output string, ignoring the rest.
public final class SimpleLogFormatter: LogFormatter {
	public init() {}

	public func formatEntry(_ entry: LogEntry) -> String {
		entry.message
	}
}
