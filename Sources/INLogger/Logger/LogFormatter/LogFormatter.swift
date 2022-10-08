import Foundation

/// The interface to any log formatter which is responsible to bring a log entry
/// into a string suitable for presentation.
public protocol LogFormatter: Sendable {
	/**
	 Formats a log entry into a string representation suitable for a pipeline.

	 - warning: Will be called on a background thread.
	 - parameter entry: The log entry with its information.
	 - returns: The readable string representing the log's information.
	 */
	func formatEntry(_ entry: LogEntry) -> String
}
