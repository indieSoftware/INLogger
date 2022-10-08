import Foundation
import INLogger

// Example of useful log tags.
public extension LogTag {
	/// Tags user actions or user initiated system actions useful to trace
	/// the user's behavior in the app to find bugs by reproducing the user's steps.
	/// It's likely that this tag has to be combined with other tags
	/// related to a specific feature.
	static let breadcrumb = LogTag(state: .enabled, name: "Breadcrumb", abbreviation: "🍞")
	/// Tags log statements made in UnitTest code.
	/// This is set to `forceDisabled` so that logs marked with this tag are never logged.
	/// However, when someone wants to enable logging during unit tests, i.e. to debug
	/// a unit test case then that person can temporarily enable this by replacing the
	/// `forceDisabled` state with `enabled`.
	static let unitTest = LogTag(state: .forceDisabled, name: "UnitTest", abbreviation: "🐞")
	/// Tags log statements made in UI tests.
	/// Set to enable to log any UI test related messages.
	static let uiTest = LogTag(state: .enabled, name: "UITest", abbreviation: "🤖")

	/// A general tag marking log statements which don't fit into any feature or module
	/// but are important enough so they should have one to be grouped.
	static let general = LogTag(state: .enabled, name: "General", abbreviation: "⭐️")
	/// An example of a tag related to a concrete feature or sub-module of the real application.
	/// This is set to `enabled` to simulate the current active development on that feature.
	static let myFeature = LogTag(state: .enabled, name: "MyFeature", abbreviation: "💝")
	/// An example of a tag that is currently disabled.
	/// Usually all feature tags should be disabled to reduce the noise in the console.
	/// Only features currently in development or some general modules like
	/// a network layer should be enabled as default.
	static let disabledTag = LogTag(state: .disabled, name: "Disabled Tag", abbreviation: "👹")
	/// An example of a force-disabled tag.
	/// This is usually used for a general flag to disable all related to that,
	/// i.e. a unit or UI test tag which is used in conjunction with other tags
	/// or a feature tag which is used together with sub-features then this
	/// global feature flag can be used to disable all sub-features even when
	/// some are enabled.
	static let forceDisabledTag = LogTag(state: .forceDisabled, name: "Force-Disabled Tag", abbreviation: "👻")
}
