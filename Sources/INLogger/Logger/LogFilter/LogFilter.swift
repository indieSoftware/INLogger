import Foundation

/// The interface to any log filter which determines if a log message
/// should get logged or ignored by the logger.
/// Implement this protocol and inject its instance to the `Logger`.
public protocol LogFilter: Sendable {
	/**
	 Determines if an entry should be logged or ignored by the pipeline.

	 - warning: Will be called on a background thread.
	 - parameter entry: The log message's info entry.
	 - returns: True if the log message should be logged, false if it should be ignored instead.
	 */
	func shouldEntryBeLogged(_ entry: LogEntry) -> Bool
}
