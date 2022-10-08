import Foundation

/// The active state of a `LogTag` defining whether a log statement should be logged
/// or not depending on its tag.
/// Keep in mind that the final decision whether a log is logged or not is made by the
/// concrete `LogFilter` implementation, therefore, the log filter takes the log tag's
/// state as a recommendation, but not as a requirement because the log level has
/// also to be taken into consideration and then it might be a difference whether
/// a development or a release log configuration is set up.
public enum LogTagState: Sendable {
	/// The tag is disabled, meaning a log statement with such a tag should be
	/// filtered out and thus not being logged.
	/// This should be the default state for all tags related to a feature when
	/// the feature is currently not in active development to not clutter up
	/// the console with logs not related to the own feature under development.
	case disabled
	/// The tag is active, meaning a log statement with such a tag should be logged.
	/// When a log statement has multiple tags then this `enabled` state has
	/// higher priority over the `disabled` state.
	/// That means when at least one tag is `enabled` among others which
	/// are `disabled` then the statement will still be logged.
	/// When currently working on a feature one might want to switch on all logs
	/// related to that feature by enabling the corresponding tag to get all messages
	/// logged to the console while actively developing on the feature.
	case enabled
	/// The tag is disabled, meaning a log statement with such a tag is filtered out
	/// and thus not being logged.
	/// When a log statement has multiple tags then this `forceDisabled` state
	/// has higher priority over the `enabled` state.
	/// That means this state is similar to the `disabled` state, but overrides the
	/// `enabled` state instead the other way around.
	/// So, when at least one tag is `forceDisabled` then it will prevent that
	/// log statement being logged.
	/// Useful for specific top level tags to generally disable all of its log statements
	/// during development.
	case forceDisabled
}

extension LogTagState: Equatable, Comparable {
	/// Returns true if both states are the same enum case, otherwise false.
	public static func == (lhs: LogTagState, rhs: LogTagState) -> Bool {
		switch (lhs, rhs) {
		case (.disabled, .disabled),
		     (.enabled, .enabled),
		     (.forceDisabled, .forceDisabled):
			return true
		default:
			return false
		}
	}

	/// Returns the order by priority (lowest first):
	/// `disabled < enabled < forceDisabled`
	public static func < (lhs: LogTagState, rhs: LogTagState) -> Bool {
		switch (lhs, rhs) {
		case (.disabled, .enabled),
		     (.disabled, .forceDisabled),
		     (.enabled, .forceDisabled):
			return true
		default:
			return false
		}
	}
}
