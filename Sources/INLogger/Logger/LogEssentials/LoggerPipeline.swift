import Foundation

/// A pipeline for the `Logger` whose responsibility is to process a log entry.
/// The default implementation ready to be used out-of-the-box is the `LogPipeline` struct.
public protocol LoggerPipeline: Sendable {
	/**
	 Processes the log entry.

	 This gets called by the logger potentially on a background thread and the
	 logger pipeline implementation's responsibility is to process this accordingly.

	 Usually a pipeline has to decide wheter a log should be processed at all,
	 then it needs to format and write it.

	 - parameter entry: The log entry to process.
	 */
	func processEntry(_ entry: LogEntry)
}
