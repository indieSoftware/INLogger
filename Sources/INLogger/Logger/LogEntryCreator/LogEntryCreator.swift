import Foundation

/// The interface to a log entry creator.
public protocol LogEntryCreator {
	/**
	 Wraps the log message and its meta-information into a log entry
	 which will then later be processed by the pipeline.

	 A log entry creator is immediately called by a logger call on the same thread
	 as that logger call and thus should take as less time to execute as possible.

	 The log entry creator gets the chance to wrap all necessary information
	 which might be necessary later for the pipeline to process.
	 That might include creating the current data/time (without formatting it)
	 for that log message or determining the current thread number which might
	 be quite time consuming.

	 The processing will happen later by the pipeline on a background thread,
	 so here we might get the chance to gather more information about the thread
	 where the call has been dispatched or other meta-data if necessary.
	 However, to keep the pre-processing time as low as possible the creator method
	 might not fill all information for the entry.
	 Only provide those information which will really be necessary later by the
	 formatter (or are cheap to wrap).

	 - parameter message: The message to log.
	 - parameter level: The severity of the log message.
	 - parameter tags: The log tags associated to that log message.
	 - parameter file: The file's name where the log message has been dispatched.
	 - parameter function: The function's name where the log message has been dispatched.
	 - parameter line: The line number in the file where the log message has been dispatched.
	 - returns: A new log entry with all relevant information suitable for the pipeline to process later.
	 */
	// swiftlint:disable:next function_parameter_count
	func createEntry(
		message: String,
		level: LogLevel,
		tags: [LogTag],
		file: String,
		function: String,
		line: Int32
	) -> LogEntry
}
