import Foundation
import INLogger

@MainActor
class ExampleViewModel: ObservableObject {
	@Published var loggerState: String = "No logger set"

	func setDevelopmentLogger() {
		LoggerSetup.developmentLogger()
		Logger.info("Development logger set", tag: .general)
		loggerState = "Development logger set"
	}

	func setSimpleLogger() {
		LoggerSetup.simpleLogger()
		Logger.info("Simple logger set", tag: .general)
		loggerState = "Simple logger set"
	}

	func setFileLogger() {
		LoggerSetup.fileLogger()
		Logger.info("File logger set", tag: .general)
		loggerState = "File logger set"
	}

	func setDisabledLogger() {
		Logger.info("Disabling logger", tag: .general)
		LoggerSetup.disabledLogger()
		loggerState = "No logger set"
	}

	@Published var breadcrumbTagEnabled: Bool = false
	@Published var generalTagEnabled: Bool = false
	@Published var myFeatureTagEnabled: Bool = false
	@Published var disabledTagEnabled: Bool = false
	@Published var forceDisabledTagEnabled: Bool = false

	@Published var logMessageText: String = "Log message"

	func logDebug() {
		Logger.debug(logMessageText, tags: gatherTags())
	}

	func logInfo() {
		Logger.info(logMessageText, tags: gatherTags())
	}

	func logWarn() {
		Logger.warn(logMessageText, tags: gatherTags())
	}

	func logError() {
		Logger.error(logMessageText, tags: gatherTags())
	}

	func logFatal() {
		Logger.fatal(logMessageText, tags: gatherTags())
	}

	private func gatherTags() -> [LogTag] {
		var tags = [LogTag]()
		if breadcrumbTagEnabled { tags.append(.breadcrumb) }
		if generalTagEnabled { tags.append(.general) }
		if myFeatureTagEnabled { tags.append(.myFeature) }
		if disabledTagEnabled { tags.append(.disabledTag) }
		if forceDisabledTagEnabled { tags.append(.forceDisabledTag) }
		return tags
	}
}
