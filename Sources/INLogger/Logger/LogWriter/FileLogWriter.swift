import Foundation
import INCommons

/**
 A log writer specific for log files used by the `Logger`'s pipeline.

 A queue ensures the ACID principles for logs written to files by this writer instance.
 However, be aware that when creating two different instances of a FileLogWriter both
 have different queues and thus might still mess up when writing to the same file,
 therefore, each writer should be responsible only for their own files and not share
 the same file with other writer.

 Any logs get written to the log file, but when a new log file is about to create then
 the old log file gets backed up.
 This makes the log file to rotate where we have a current log file and an old log file
 with a total of up to two log files for rotation.
 */
public final class FileLogWriter: LogWriter, @unchecked Sendable {
	/// The default folder for log files.
	public static let defaultLogFolder = FileManager.documentsDirectory
	/// The default file name for the log file.
	public static let defaultLogFileName = "logfile.txt"
	/// The default file name for the rotating backup file.
	public static let defaultBackupName = "last_logfile.txt"

	/// This queue ensures the ACID principles for logs written to files
	/// by this writer instance.
	/// Keep in mind that when creating two different instances of a writer
	/// both have different queues and thus might still mess up when interacting
	/// with the same file, therefore, each writer should be responsible
	/// only for their own files and not share the same file with other writer.
	let writerQueue = DispatchQueue(label: "INLogger.FileLogWriter.writerQueue", qos: .utility)

	/// The folder where to save the log and backup file.
	public let fileFolder: URL
	/// The URL to the log file.
	public let logFilePath: URL
	/// The URL to the rotating backup log file.
	public let backupFilePath: URL

	/// A closure to which inform internal errors.
	private let internalErrorReporter: @Sendable (FileLogWriterError) -> Void

	/**
	 Instantiates a new log file writer.

	 As part of the initialization a new log file will be created which might lead
	 to a backup of the old one.

	 - parameter fileName: The name of the file where to write any log statements to.
	 - parameter backupName: The name of the backup file where to save the log file
	 when a new gets created.
	 - parameter folder: An URL to the folder where to save the log and backup files.
	 Defaults to the documents directory.
	 - parameter redirectStderrToLogfile: Set to `true` to redirect the
	 standard error stream to the log file to make sure also any `print` and
	 `NSLog` statements are logged from 3rd party libs.
	 Be aware that this can muddle the log file because it can happen that the
	 log writer is trying to write something to the file in the same time as the
	 stderr stream is sending to the file.
	 Therefore, that can cause log statements in the file being interrupted by other statement
	 intersecting them.
	 Also it's only possible to direct the stderr to one log file, therefore, don't set
	 to true for more than one `FileLogWriter` instance.
	 Defaults to `false`.
	 - parameter internalErrorReporter: A closure to which internal errors are reported.
	 Defaultly this just prints the error via `NSLog.
	 Since we are part of the logger itself we can't use the logger to log an error
	 related to the Logger, therefore, we are using this reporter to have
	 at least a chance during development to find problems related to the
	 `FileLogWriter` and we can hook into this for UnitTests to verify any
	 error messages.
	 */
	public init(
		fileName: String = defaultLogFileName,
		backupName: String = defaultBackupName,
		folder: URL = defaultLogFolder,
		redirectStderrToLogfile: Bool = false,
		internalErrorReporter: @Sendable @escaping (FileLogWriterError) -> Void = { error in
			NSLog("ERROR - Logger.FileLogWriter: \(error.description)")
		}
	) {
		fileFolder = folder
		logFilePath = folder.appendingPathComponent(fileName)
		backupFilePath = folder.appendingPathComponent(backupName)
		self.internalErrorReporter = internalErrorReporter

		createNewLogFile(redirectStderrToLogfile: redirectStderrToLogfile)
	}

	deinit {
		// Necessary to close the handle if one is open.
		logFileHandle = nil
	}

	/// Initiates a log file rotation by backing up any current log file and creating a new one.
	private func createNewLogFile(redirectStderrToLogfile: Bool) {
		writerQueue.async {
			let fileManager = FileManager.default

			// Delete backup file if it exists.
			if fileManager.fileExists(atPath: self.backupFilePath.path) {
				do {
					try fileManager.removeItem(at: self.backupFilePath)
				} catch {
					self.internalErrorReporter(.backupLogFileCouldNotBeDeleted(error))
				}
			}

			// Rename log file to backup file if one exists.
			if fileManager.fileExists(atPath: self.logFilePath.path) {
				do {
					try fileManager.moveItem(at: self.logFilePath, to: self.backupFilePath)
				} catch {
					self.internalErrorReporter(.logFileCouldNotBeBackedUp(error))
				}
			}

			// Ensure folder for files exist.
			var fileFolderIsDirectory: ObjCBool = false
			if !fileManager.fileExists(atPath: self.fileFolder.path, isDirectory: &fileFolderIsDirectory) {
				do {
					try fileManager.createDirectory(at: self.fileFolder, withIntermediateDirectories: true, attributes: nil)
				} catch {
					self.internalErrorReporter(.logFolderCouldNotBeCreated(error))
				}
			} else {
				guard fileFolderIsDirectory.boolValue else {
					self.internalErrorReporter(.logFolderExistsButIsNotAFolder)
					return
				}
			}

			// Create empty log file and open it for writing.
			guard fileManager.createFile(atPath: self.logFilePath.path, contents: nil, attributes: nil) else {
				self.internalErrorReporter(.logFileCouldNotBeCreated)
				return
			}
			do {
				self.logFileHandle = try FileHandle(forWritingTo: self.logFilePath)
			} catch {
				self.internalErrorReporter(.logFileCouldNotBeOpenForWriting(error))
			}

			// Redirect standard error stream to log file.
			if redirectStderrToLogfile {
				freopen(self.logFilePath.path.cString(using: String.Encoding.utf8), "a", stderr)
			}
		}
	}

	private var logFileHandle: FileHandle? {
		didSet {
			// When we are assigning a new handler (or nil) we close an old first.
			if let oldHandle = oldValue {
				do {
					try oldHandle.close()
				} catch {
					internalErrorReporter(.logFileCouldNotBeClosed(error))
				}
			}
		}
	}

	public func write(_ message: String) {
		writerQueue.async {
			guard let handle = self.logFileHandle else {
				self.internalErrorReporter(.noLogFileHandlerAvailable)
				return
			}

			guard let data = "\(message)\n".data(using: .utf8) else {
				self.internalErrorReporter(.messageCouldNotBeEncodedToData(message))
				return
			}

			handle.write(data)
			do {
				try handle.synchronize()
			} catch {
				self.internalErrorReporter(.logFileCouldNotBeWritten(error))
			}
		}
	}

	/// Points to a specific log file type and defines what to return
	/// when requesting for the log file's content.
	public enum LogFileType {
		/// Points to the current log file, therefore, only the log file's content is returned.
		/// The backup file is ignored.
		case logFile
		/// Points to the backup file, therefore, only the backup file's content is returned.
		/// The current log file itself is ignored.
		case backupFile
	}

	/**
	 Returns the content of the log file.

	 - parameter fileType: Define which file's content should be returned.
	 - returns: The content of the specified log file or nil if none could be read.
	 */
	public func contentOfLog(fileType: LogFileType) -> String? {
		let fileUrl: URL
		switch fileType {
		case .logFile:
			fileUrl = logFilePath
		case .backupFile:
			fileUrl = backupFilePath
		}

		// Use sync here because we want to return the content immediately
		// and synchronously, but we have to make sure that no other write
		// request is still in progress.
		writerQueue.sync {}

		guard let fileHandle = FileHandle(forReadingAtPath: fileUrl.path) else {
			return nil
		}
		return String(data: fileHandle.availableData, encoding: .utf8)
	}
}
