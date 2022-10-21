import Foundation

/// The supported log levels of the `Logger` indicating the severity of the log message.
/// When iterating over the log levels then they are ordered from lest to most severe.
public enum LogLevel: CaseIterable, Comparable, Sendable {
	/// A message which typically should only be logged during development and thus not
	/// logged in a release build.
	/// Usually this is used to log information which is only interesting when actively working
	/// on a feature as a developer, i.e. service call details.
	case debug
	/// An info message which provides some general information and which will be logged
	/// even in release builds to have some general information for tracing bugs.
	/// Usually this is used to log general information of the app state which might help
	/// the customer support or a developer to reproduce bugs, i.e. the app version.
	case info
	/// A waning indicating that something didn't went the happy path, but not totally wrong either,
	/// so we can recover from it and continue.
	/// Usually this is used to log situations which should give the customer support or
	/// a developer a hint that something didn't work as expected, i.e. a memory warning.
	case warn
	/// An error message indicating that something has gone totally wrong, but we still might recover
	/// to a consistent app state.
	/// Usually this is used to log errors, i.e. that parsing a service call response failed.
	case error
	/// A fatal error from which it's not possible to recover and thus most likely leads to a crash
	/// via `fatalError` right after this call.
	/// Usually this is used to log a critical error, i.e. an impossible state of the app.
	case fatal
}
