import Foundation

/// The interface for any log writer which is responsible
/// to write a formatted log string to its correct place,
/// i.e. to the console or a log file.
public protocol LogWriter: Sendable {
	/**
	 Writes the formatted log message string where it belongs to.

	 Keep in mind that this method will be called on a background thread.
	 It will be always on the same queue for all writers, so when they are
	 all synchronous they shouldn't interfere each other, but they might
	 block others.
	 Therefore, consider wrapping the actual writing on a different thread
	 so that other writers are not delayed too long.

	 However, keep also in mind, that some persistence methods might
	 interfere with each other.
	 For example when writing to the console it might be interupted by a
	 different console log on a different thread.
	 That might happen when some third party libs are using `print`
	 statements or `NSLog`.
	 The result will then be that lines get truncated and mixed up when
	 they are not all processed on the main thread.

	 - warning: Will be called on a background thread.
	 - parameter message: The formatted log message as a string.
	 */
	func write(_ message: String)
}
