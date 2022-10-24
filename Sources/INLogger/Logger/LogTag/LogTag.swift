import Foundation

/// A tag which can be used to mark log messages.
public struct LogTag: Sendable {
	/// The log tag's state, i.e. if this tag is disabled or enabled.
	public let state: LogTagState
	/// The tag's representation name.
	public let name: String
	/// The tag's short representation.
	public let abbreviation: String?

	/**
	 Creates a log tag.

	 - parameter state: The log's state indicating whether it is active and should be logged
	 or it is inactive and thus should not be logged.
	 - parameter name: The tag's name in its log version which can be used by
	 the logger's `LogFormatter`.
	 - parameter abbreviation: A short indicator for the tag usually an emoji
	 which can be used by the logger's `LogFormatter` for a compressed output form.
	 */
	public init(state: LogTagState, name: String, abbreviation: String? = nil) {
		self.state = state
		self.name = name
		self.abbreviation = abbreviation
	}
}

extension LogTag: Equatable {}

public extension [LogTag] {
	/**
	 Returns the `LogTagState` with the highest priority of all `LogTag` states in this list.

	 The highest priority is determined by comparing the states of all tags
	 and returning the one with the highest priority.
	 The order is provided by the `LogTagState`'s `Comparable` order,
	 which is as follows (highest first):
	 `forceDisabled > enabled > disabled`

	 However, when the array is empty then `enabled` will be returned.
	 */
	var highestPriorityLogTagState: LogTagState {
		if isEmpty {
			return .enabled
		}
		let logTagStates = map(\.state)
		return logTagStates.reduce(LogTagState.disabled) { result, state in
			state > result ? state : result
		}
	}
}
