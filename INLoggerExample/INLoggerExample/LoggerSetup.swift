import Foundation
import INLogger

/// Some convenience Logger setups.
/// Run one of these setup methods during app start to create a corresponding shared Logger instance.
public enum LoggerSetup {
	@MainActor
	public static func simpleLogger() {
		let consoleLogPipeline = LogPipeline(
			filter: DevelopmentLogFilter(),
			formatter: SimpleLogFormatter(),
			writer: [ConsoleLogWriter()]
		)
		Logger.shared = Logger(
			entryCreator: SimpleLogEntryCreator(),
			pipelines: [consoleLogPipeline]
		)
	}

	@MainActor
	public static func developmentLogger() {
		let consoleLogPipeline = LogPipeline(
			filter: DevelopmentLogFilter(),
			formatter: DevelopLogFormatter(),
			writer: [ConsoleLogWriter()]
		)
		Logger.shared = Logger(
			entryCreator: SimpleLogEntryCreator(),
			pipelines: [consoleLogPipeline]
		)
	}

	@MainActor
	public static func fileLogger() {
		let consoleLogPipeline = LogPipeline(
			filter: ReleaseLogFilter(),
			formatter: FileLogFormatter(),
			writer: [ConsoleLogWriter()]
		)
		let fileLogWriter = FileLogWriter(redirectStderrToLogfile: true)
		let fileLogPipeline = LogPipeline(
			filter: ReleaseLogFilter(),
			formatter: FileLogFormatter(),
			writer: [fileLogWriter]
		)
		Logger.shared = Logger(
			entryCreator: SimpleLogEntryCreator(),
			pipelines: [consoleLogPipeline, fileLogPipeline]
		)

		Logger.shared.info("Log file path: \(fileLogWriter.fileFolder.path)", tag: .general)
	}

	@MainActor
	public static func disabledLogger() {
		Logger.shared = Logger(entryCreator: SimpleLogEntryCreator(), pipelines: [])
	}
}
