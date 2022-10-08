import Foundation

/// A log writer which prints any log messages to the console
/// via a `print` statement.
public final class ConsoleLogWriter: LogWriter {
	public init() {}

	public func write(_ message: String) {
		print(message)
	}
}
