import INCommons
@testable import INLogger
import XCTest

@MainActor
class FileLogWriterTests: XCTestCase, Sendable {
	var fileUrl: URL!
	var backupUrl: URL!

	let defaultErrorReporter: @Sendable (FileLogWriterError) -> Void = { error in
		XCTFail("Writer error: \(error)")
	}

	override func setUp() async throws {
		try await super.setUp()
		// This is the writer's default as provided by its init parameter.
		let documentsDirectory = FileManager.documentsDirectory
		fileUrl = documentsDirectory.appendingPathComponent(FileLogWriter.defaultLogFileName)
		backupUrl = documentsDirectory.appendingPathComponent(FileLogWriter.defaultBackupName)

		// Remove any files from previous tests.
		try? FileManager.default.removeItem(at: fileUrl)
		try? FileManager.default.removeItem(at: backupUrl)
	}

	// MARK: - Init

	func testLogFileIsCreatedOnInit() throws {
		XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
		XCTAssertFalse(FileManager.default.fileExists(atPath: backupUrl.path))

		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))
		XCTAssertFalse(FileManager.default.fileExists(atPath: backupUrl.path))
	}

	func testCreatedLogFileIsEmpty() throws {
		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		let handle = try XCTUnwrap(FileHandle(forReadingAtPath: fileUrl.path))
		let result = String(data: handle.availableData, encoding: .utf8)

		XCTAssertEqual(result, "")
	}

	func testWritingToLogFileWorks() throws {
		let message = "Foo"
		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			writer.write(message)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		let handle = try XCTUnwrap(FileHandle(forReadingAtPath: fileUrl.path))
		let result = String(data: handle.availableData, encoding: .utf8)

		XCTAssertEqual(result, "\(message)\n")
	}

	func testWritingMultipleTimesAppendsWrites() throws {
		let message1 = "Foo"
		let message2 = "Bar"
		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			writer.write(message1)
			writer.write(message2)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		let handle = try XCTUnwrap(FileHandle(forReadingAtPath: fileUrl.path))
		let result = String(data: handle.availableData, encoding: .utf8)

		XCTAssertEqual(result, "\(message1)\n\(message2)\n")
	}

	func testExistingLogFileGetsBackedUpOnInit() throws {
		let message1 = "Foo"
		let message2 = "Bar"

		// Create a writer instance and write a message to the log file.
		// Wrap this code in a closure to make sure the writer has been released
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			writer.write(message1)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		// Creates a new writer instance which rotates the log file to the backup file.
		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			writer.write(message2)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		// We are expecting that both files exist and that the content matches.
		XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))
		XCTAssertTrue(FileManager.default.fileExists(atPath: backupUrl.path))

		let logFileHandle = try XCTUnwrap(FileHandle(forReadingAtPath: fileUrl.path))
		let logFileContent = String(data: logFileHandle.availableData, encoding: .utf8)
		XCTAssertEqual(logFileContent, "\(message2)\n")

		let backupFileHandle = try XCTUnwrap(FileHandle(forReadingAtPath: backupUrl.path))
		let backupFileContent = String(data: backupFileHandle.availableData, encoding: .utf8)
		XCTAssertEqual(backupFileContent, "\(message1)\n")
	}

	func testWritersWorksWithCustomFileParameters() throws {
		// Use a subfolder which doesn't exist to verify the writer creates it
		let directory = FileManager.documentsDirectory
			.appendingPathComponent("subTestFolder/logs")
		let fileName = "FooTest.txt"
		let backupName = "BarTest.txt"
		fileUrl = directory.appendingPathComponent(fileName)
		backupUrl = directory.appendingPathComponent(backupName)

		// Remove folder from previous tests.
		try? FileManager.default.removeItem(at: directory)

		// Sanity tests.
		XCTAssertFalse(FileManager.default.fileExists(atPath: fileUrl.path))
		XCTAssertFalse(FileManager.default.fileExists(atPath: backupUrl.path))

		let message1 = "Bar"
		let message2 = "Foo"

		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(fileName: fileName, backupName: backupName, folder: directory)
			writer.write(message1)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(fileName: fileName, backupName: backupName, folder: directory)
			writer.write(message2)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		// We expect that both files have been created and the writes are persisted.
		XCTAssertTrue(FileManager.default.fileExists(atPath: fileUrl.path))
		XCTAssertTrue(FileManager.default.fileExists(atPath: backupUrl.path))

		let logFileHandle = try XCTUnwrap(FileHandle(forReadingAtPath: fileUrl.path))
		let logFileContent = String(data: logFileHandle.availableData, encoding: .utf8)
		XCTAssertEqual(logFileContent, "\(message2)\n")

		let backupFileHandle = try XCTUnwrap(FileHandle(forReadingAtPath: backupUrl.path))
		let backupFileContent = String(data: backupFileHandle.availableData, encoding: .utf8)
		XCTAssertEqual(backupFileContent, "\(message1)\n")
	}

	func testWriterFailsWhenProvidedFolderIsAFile() throws {
		let directory = FileManager.documentsDirectory.appendingPathComponent("notAFolder")

		// Remove folder/file from previous tests and create a new file instead of a folder.
		try? FileManager.default.removeItem(at: directory)
		XCTAssertTrue(FileManager.default.createFile(atPath: directory.path, contents: nil, attributes: nil))

		// Sanity tests.
		XCTAssertTrue(FileManager.default.fileExists(atPath: directory.path))

		let errorExpectation = expectation(description: "errorExpectation")
		let errorReporter: @Sendable (FileLogWriterError) -> Void = { error in
			guard case FileLogWriterError.logFolderExistsButIsNotAFolder = error else {
				XCTFail("Wrong error: \(error)")
				return
			}
			errorExpectation.fulfill()
		}

		// This tries to create the file in a folder which is actually a file and not a folder.
		let writer = FileLogWriter(folder: directory, internalErrorReporter: errorReporter)

		// Block this thread until the file writer has done its work.
		writer.writerQueue.sync {}
		waitForExpectations(timeout: 1)
	}

	// MARK: - ContentOfLog

	func testContentOfLogReturnsContentOfLogFile() throws {
		let message = "Foo"
		let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
		writer.write(message)

		let result = writer.contentOfLog(fileType: .logFile)

		XCTAssertEqual(result, "\(message)\n")
	}

	func testContentOfLogReturnsContentOfBackupFile() throws {
		let message = "Foo"
		// Wrap this code in a closure to make sure the writer has been released.
		_ = {
			let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)
			writer.write(message)
			// Block this thread until the file writer has done its work.
			writer.writerQueue.sync {}
		}()

		let writer = FileLogWriter(internalErrorReporter: defaultErrorReporter)

		let result = writer.contentOfLog(fileType: .backupFile)

		XCTAssertEqual(result, "\(message)\n")
	}
}
