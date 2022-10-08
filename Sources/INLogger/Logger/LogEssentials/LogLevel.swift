import Foundation

/// The supported log levels of the `Logger` indicating the severity of the log message.
/// When iterating over the log levels then they are ordered from lest to most severe.
public enum LogLevel: CaseIterable, Comparable, Sendable {
	/// A message which typically should only be logged during debugging while in development.
	case debug
	/// An info message which provides some general information and which will be logged
	/// even in release builds to have some breadcrumbs for tracing bugs.
	case info
	/// A waning indicating that something didn't went the happy path, but not totally wrong either,
	/// so we can recover from it and continue.
	case warn
	/// An error message indicating that something has gone totally wrong, but we still might recover
	/// to a consistent app state.
	case error
	/// A fatal error from which it's not possible to recover and thus most likely leads to a crash
	/// via `fatalError` right after this call.
	case fatal
}
