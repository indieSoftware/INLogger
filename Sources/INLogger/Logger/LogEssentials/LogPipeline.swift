import Foundation

/// A concrete pipeline implementation for the `Logger` is a combination of a
/// filter, formatter and writer to process a logged message entry.
public struct LogPipeline: LoggerPipeline, Sendable {
	/// The filter which determines if a log message should be processed or not.
	let filter: LogFilter
	/// The formatter which formats a log message entry into a string suitable for the writer.
	let formatter: LogFormatter
	/// A list of writers where each gets the log message string is passed to for writing it.
	let writer: [LogWriter]

	/**
	 Creates a pipeline for the `Logger`.

	 Each pipeline processes a log entry.
	 The flow is as follows:

	 1. The filter determines if the log entry should be filtered out
	 or processed by the pipeline.
	 2. The entry gets formatted by the formatter into a readable string
	 containing all necessary information in a readable manner.
	 3. The formatted message gets passed to all writers to print
	 or persist the formatted message.

	 - parameter filter: A log filter which determines if a log message should be logged or filtered out.
	 - parameter formatter: A log formatter which transforms the log message with all its meta
	 information into a formatted string.
	 - parameter writer: Any number of writers which are responsible to write the formatted log message
	 to the console or a file or whatever the writer wants to do with it.
	 The writers are called in the order provided in the array.
	 */
	public init(filter: LogFilter, formatter: LogFormatter, writer: [LogWriter]) {
		self.filter = filter
		self.formatter = formatter
		self.writer = writer
	}

	/**
	 Processes the log entry.

	 This method first asks the filter if that entry should be logged by the pipeline at all.
	 Then, if passed, the log message gets formatted into a printable string representable.
	 That string gets then passed to all registered writers of this pipeline.

	 - parameter entry: The log info to process.
	 */
	public func processEntry(_ entry: LogEntry) {
		// Ignore log entry when the filter wants to filter it out.
		guard filter.shouldEntryBeLogged(entry) else {
			return
		}

		// Format the log entry into a string.
		let formattedString = formatter.formatEntry(entry)

		// Pass the formatted log message to all writers.
		writer.forEach { writer in
			writer.write(formattedString)
		}
	}
}
