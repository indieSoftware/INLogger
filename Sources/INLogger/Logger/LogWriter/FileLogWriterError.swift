import Foundation

/// Errors which can arise in the `FileLogWriter`, but can't be logged nor should they be thrown.
/// To get informed of them assign a custom closure to the writer's static variable `logInternalError`.
public enum FileLogWriterError: Error, CustomStringConvertible, Sendable {
	case backupLogFileCouldNotBeDeleted(Error)
	case logFileCouldNotBeBackedUp(Error)
	case logFolderCouldNotBeCreated(Error)
	case logFolderExistsButIsNotAFolder
	case logFileCouldNotBeCreated
	case logFileCouldNotBeOpenForWriting(Error)
	case logFileCouldNotBeClosed(Error)
	case noLogFileHandlerAvailable
	case messageCouldNotBeEncodedToData(_ message: String)
	case logFileCouldNotBeWritten(Error)

	public var description: String {
		switch self {
		case let .backupLogFileCouldNotBeDeleted(error):
			return "Backup log file couldn't be deleted: \(error.localizedDescription)"
		case let .logFileCouldNotBeBackedUp(error):
			return "Log file couldn't be backed up: \(error.localizedDescription)"
		case let .logFolderCouldNotBeCreated(error):
			return "Log's folder couldn't be created: \(error.localizedDescription)"
		case .logFolderExistsButIsNotAFolder:
			return "Log's folder exists, but is not a folder!"
		case .logFileCouldNotBeCreated:
			return "Log file couldn't be created!"
		case let .logFileCouldNotBeOpenForWriting(error):
			return "Log file couldn't be open for writing: \(error.localizedDescription)"
		case let .logFileCouldNotBeClosed(error):
			return "Log file couldn't be closed: \(error.localizedDescription)"
		case .noLogFileHandlerAvailable:
			return "No log file handler available!"
		case let .messageCouldNotBeEncodedToData(message):
			return "Message couldn't be encoded to a data object: '\(message)'"
		case let .logFileCouldNotBeWritten(error):
			return "Log file couldn't be written to: \(error.localizedDescription)"
		}
	}
}
