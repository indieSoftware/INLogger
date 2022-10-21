import Foundation

/// A logger for collecting debug or other info messages in code and to process them
/// by writing them to the console or a file.
public final class Logger {
	/// A reference to the singleton instance of the `Logger`.
	///
	/// The default one has no pipelines injected and thus does not log anything,
	/// which makes it work with previews and unit tests.
	/// However, for the productive app the default logger should be replaced on app start
	/// with a logger which has some pipelines assigned to make use of the logging.
	/// This is only necessary when using the static log methods of the `Logger` class.
	/// When not relying on the static methods, but on a concrete instance which gets
	/// injected to each class who wants to log then this shared logger property can be ignored.
	///
	/// When creating a new logger instance then consider using different configurations
	/// by injecting different pipelines for different builds, i.e. inject a console writer instead
	/// of a file writer for debug builds compared to release builds.
	public static var shared: Logger = .init(entryCreator: SimpleLogEntryCreator(), pipelines: [])

	/// The queue on which the pipelines are processing the log entries.
	/// This ensures that each log is processed sequentially.
	let processingQueue = DispatchQueue(label: "INLogger.Logger.processingQueue", qos: .utility)

	/// The creator instance which is used to create raw log entries before passing them to the pipelines.
	private let entryCreator: LogEntryCreator
	/// The pipelines used to process any raw log entries on a background thread.
	private let pipelines: [LoggerPipeline]

	/**
	 Initializes a logger with some pipelines.

	 Each pipeline is responsible for processing a log message and each log message
	 is passed to each pipeline in their order in the array.
	 With multiple pipelines it's possible to configure the logger to have specific messages
	 being formatted and logged differently, i.e. one pipeline might log all debug messages,
	 but only to the console while a different pipeline only logs non-debug logs and writes
	 them to a log file.

	 - parameter entryCreator: A log entry creator which has to wrap the log message
	 and its meta-data into a log entry ready to be processed by the other components of the pipeline.
	 - parameter pipelines: All pipelines which should process the logs.
	 If no pipeline is passed then no log will be processed and thus nothing will be logged.
	 */
	public init(entryCreator: LogEntryCreator, pipelines: [LoggerPipeline]) {
		self.entryCreator = entryCreator
		self.pipelines = pipelines
	}

	/**
	 Logs a log entry by passing it to all registered pipelines.

	 The log meta-information will be passed to the entry creator to create an entry of it.
	 That entry will then be passed on a background thread to all the registered pipelines
	 for processing.

	 - parameter message: The message to log.
	 - parameter level: The severity of the log message.
	 - parameter tags: An array of associated log tags for this message.
	 - parameter processOnThread: When set to true then the log entry will be processed by a queue immediately on
	 the same thread. When set to false then the log entry will be passed to the pipeline on a background thread.
	 Defaults to false because usually a log entry should be processed on a background thread to not block the current thread's
	 execution, however, when a crash is imminent then a background thread might be too late and the log might be lost.
	 Therefore, in such circumstances, e.g. for logs with a fatal severity, it's possible to by-pass the background queue by
	 providing true as parameter.
	 - parameter file: The file's name where the log message has been dispatched. Will be automatically set.
	 - parameter function: The function's name where the log message has been dispatched. Will be automatically set.
	 - parameter line: The line number in the file where the log message has been dispatched. Will be automatically set.
	 */
	public func log(
		message: String,
		level: LogLevel,
		tags: [LogTag],
		processOnThread: Bool = false,
		file: String = #file,
		function: String = #function,
		line: Int32 = #line
	) {
		let entry = entryCreator.createEntry(message: message, level: level, tags: tags, file: file, function: function, line: line)

		let capturedPipelines = pipelines
		if processOnThread {
			capturedPipelines.forEach { pipeline in
				pipeline.processEntry(entry)
			}
		} else {
			processingQueue.async {
				capturedPipelines.forEach { pipeline in
					pipeline.processEntry(entry)
				}
			}
		}
	}

	// MARK: - Convenience methods

	public func debug(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .debug, tags: tags, file: file, function: function, line: line)
	}

	public func debug(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .debug, tags: [tag], file: file, function: function, line: line)
	}

	public func info(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .info, tags: tags, file: file, function: function, line: line)
	}

	public func info(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .info, tags: [tag], file: file, function: function, line: line)
	}

	public func warn(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .warn, tags: tags, file: file, function: function, line: line)
	}

	public func warn(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .warn, tags: [tag], file: file, function: function, line: line)
	}

	public func error(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .error, tags: tags, file: file, function: function, line: line)
	}

	public func error(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .error, tags: [tag], file: file, function: function, line: line)
	}

	public func fatal(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .fatal, tags: tags, processOnThread: true, file: file, function: function, line: line)
	}

	public func fatal(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		log(message: message, level: .fatal, tags: [tag], processOnThread: true, file: file, function: function, line: line)
	}

	// MARK: - Static methods

	public static func debug(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .debug, tags: tags, file: file, function: function, line: line)
	}

	public static func debug(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .debug, tags: [tag], file: file, function: function, line: line)
	}

	public static func info(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .info, tags: tags, file: file, function: function, line: line)
	}

	public static func info(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .info, tags: [tag], file: file, function: function, line: line)
	}

	public static func warn(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .warn, tags: tags, file: file, function: function, line: line)
	}

	public static func warn(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .warn, tags: [tag], file: file, function: function, line: line)
	}

	public static func error(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .error, tags: tags, file: file, function: function, line: line)
	}

	public static func error(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .error, tags: [tag], file: file, function: function, line: line)
	}

	public static func fatal(_ message: String, tags: [LogTag] = [], file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .fatal, tags: tags, processOnThread: true, file: file, function: function, line: line)
	}

	public static func fatal(_ message: String, tag: LogTag, file: String = #file, function: String = #function, line: Int32 = #line) {
		Logger.shared.log(message: message, level: .fatal, tags: [tag], processOnThread: true, file: file, function: function, line: line)
	}
}
