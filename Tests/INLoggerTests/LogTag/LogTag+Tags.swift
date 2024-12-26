import INLogger

public extension LogTag {
	static let unitTest = LogTag(state: .forceDisabled, name: "UnitTest", abbreviation: "🐞")
	static let general = LogTag(state: .enabled, name: "General", abbreviation: "⭐️")
	static let breadcrumb = LogTag(state: .enabled, name: "Breadcrumb", abbreviation: "🍞")
}
