@testable import INLogger
import XCTest

class LoggerConcurrencyTests: XCTestCase {
	func testLoggerEnqueuesLogs() {
		/// We are collecting here the order of the writer calls by their
		/// unique ID together with the message processed.
		var writerCalls = [WriterCall]()

		/// This is the first message which gets passed to two pipelines and starts the test.
		let startMessage = "Start Message"
		/// This message is logged when `startMessage` is processed by writer 11.
		let interruptingMessage1 = "Interrupting Message 1"
		/// This message is logged when `startMessage` is processed by writer 21.
		let interruptingMessage2 = "Interrupting Message 2"

		/// The start message is processed once per pipeline component,
		/// but the first message will trigger the two interrupting message logs,
		/// thus each component is called three times.
		/// However, the filter and formatter is used twice, in each of the two pipelines once,
		/// thus for them the messages have to be doubled.
		let totalMessagesLogged = 3

		/// When the logger enqueues each log correctly then `startMessage` has to be
		/// processed by all writers before any writer starts processing
		/// `interruptingMessage1` or `interruptingMessage2`.
		/// And `interruptingMessage1` has to be processed by all writers
		/// before `interruptingMessage2`.
		let expectedCalls: [WriterCall] = [
			WriterCall(11, startMessage),
			WriterCall(12, startMessage),
			WriterCall(21, startMessage),
			WriterCall(22, startMessage),
			WriterCall(11, interruptingMessage1),
			WriterCall(12, interruptingMessage1),
			WriterCall(21, interruptingMessage1),
			WriterCall(22, interruptingMessage1),
			WriterCall(11, interruptingMessage2),
			WriterCall(12, interruptingMessage2),
			WriterCall(21, interruptingMessage2),
			WriterCall(22, interruptingMessage2)
		]

		let logFilterExpectation = expectation(description: "logFilterExpectation")
		logFilterExpectation.expectedFulfillmentCount = totalMessagesLogged * 2
		let logFilter = LogFilterMock()
		logFilter.shouldEntryBeLoggedMock = { _ in
			logFilterExpectation.fulfill()
			return true // Just pass and process the pipeline
		}

		let logFormatterExpectation = expectation(description: "logFormatterExpectation")
		logFormatterExpectation.expectedFulfillmentCount = totalMessagesLogged * 2
		let logFormatter = LogFormatterMock()
		logFormatter.formatEntryMock = { entry in
			logFormatterExpectation.fulfill()
			return entry.message
		}

		let logWriter11 = LogWriterMock()
		let logWriter12 = LogWriterMock()
		let logWriter21 = LogWriterMock()
		let logWriter22 = LogWriterMock()

		let logEntryCreator = SimpleLogEntryCreator()

		let pipeline1 = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter11, logWriter12])
		let pipeline2 = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter21, logWriter22])

		let logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline1, pipeline2])

		// Configuration of the writers.

		let logWriter11Expectation = expectation(description: "logWriter11Expectation")
		logWriter11Expectation.expectedFulfillmentCount = totalMessagesLogged
		logWriter11.writeMock = { message in
			writerCalls.append(WriterCall(11, message))
			// Writer 11 gets triggered by the start message to
			// immediately log the interrupting message 1.
			if message == startMessage {
				logger.debug(interruptingMessage1)
			}
			logWriter11Expectation.fulfill()
		}

		let logWriter12Expectation = expectation(description: "logWriter12Expectation")
		logWriter12Expectation.expectedFulfillmentCount = totalMessagesLogged
		logWriter12.writeMock = { message in
			writerCalls.append(WriterCall(12, message))
			logWriter12Expectation.fulfill()
		}

		let logWriter21Expectation = expectation(description: "logWriter21Expectation")
		logWriter21Expectation.expectedFulfillmentCount = totalMessagesLogged
		logWriter21.writeMock = { message in
			writerCalls.append(WriterCall(21, message))
			// Writer 21 gets triggered by the start message to
			// immediately log the interrupting message 2.
			if message == startMessage {
				logger.debug(interruptingMessage2)
			}
			logWriter21Expectation.fulfill()
		}

		let logWriter22Expectation = expectation(description: "logWriter22Expectation")
		logWriter22Expectation.expectedFulfillmentCount = totalMessagesLogged
		logWriter22.writeMock = { message in
			writerCalls.append(WriterCall(22, message))
			logWriter22Expectation.fulfill()
		}

		// This starts the test.
		logger.debug(startMessage)

		waitForExpectations(timeout: 1)

		XCTAssertEqual(writerCalls, expectedCalls)
	}

	/// When the side-effect is not executed immediately then it will be
	/// called on the logger's queue and that might lead to crashes because
	/// of race-coditions or when a specific execution thread is expected.
	/// This test verifies that the crash IDI-8176 has been fixed.
	func testMessageSideEffectsAreImmediatelyExecutedOnLogCall() {
		let printActive = false // when true then the debugPrint messages print
		// the comments to the console, useful for debugging this test
		func debugPrint(_ message: String) { if printActive { print(message) } }

		let logEntryCreator = SimpleLogEntryCreator()
		let logFilter = LogFilterMock()
		logFilter.shouldEntryBeLoggedMock = { _ in
			true // Just pass and process the pipeline
		}
		let logFormatter = LogFormatterMock()
		logFormatter.formatEntryMock = { entry in
			entry.message // Just return the message
		}
		let logWriter = LogWriterMock()
		logWriter.writeMock = { _ in }

		let pipeline = LogPipeline(filter: logFilter, formatter: logFormatter, writer: [logWriter])
		let logger = Logger(entryCreator: logEntryCreator, pipelines: [pipeline])

		// The variable which will be changed as a side-effect of the log message.
		var sideEffectVariable = 1

		// The lock will be used to block threads like the logger's queue on specific points
		// to simulate specific race-conditions.
		let lock = NSRecursiveLock()
		lock.lock()

		let loggerQueueStartedExpectation = expectation(description: "loggerQueueStartedExpectation")
		// Inject a block to the logger's queue which blocks the queue from execution.
		// This ensures that the log message is not executed on the logger's queue
		// because the queue is locked.
		logger.processingQueue.async {
			debugPrint("logger queue started processing")
			// Informs the test thread that the logger's queue has been started processing.
			loggerQueueStartedExpectation.fulfill()
			// Here we block the logger's queue waiting for the test to finish.
			lock.lock()
			debugPrint("logger queue continues processing")
			lock.unlock()
		}

		// This closure performs a side-effect by manipulating the sideEffectVariable variable
		// before returning it to the log message.
		let sideEffect: () -> Int = {
			debugPrint("side effect block is executing")
			// Here we perform the side-effect.
			sideEffectVariable += 1
			return sideEffectVariable
		}

		debugPrint("executing log statement")
		// This log message performs a side-effect when the message text is processed.
		// This test ensures that this side-effect happens immediately and thus
		// is not delayed to some time later being executed on a different thread.
		logger.info("Log: \(sideEffect())")

		debugPrint("waiting for logger queue")
		// Ensures that the logger queue has been startet before continuing the test.
		waitForExpectations(timeout: 1)
		debugPrint("logger queue has been started, continuing with test")

		// This is actually the real test which ensures that the side-effect is happening
		// right during the log message and not some time later.
		// Since the logger's queue is blocked we can ensure that the log statement has not been
		// processed by the logger, so the sideEffectVariable could only have been changed
		// when the side-effect happened right on the call statement.
		XCTAssertEqual(sideEffectVariable, 2, "Side-effect has not happened")

		// Test has passed, we can now unblock the logger's queue.
		lock.unlock()
	}
}

private struct WriterCall: Equatable, CustomStringConvertible {
	let id: Int
	let message: String

	init(_ id: Int, _ message: String) {
		self.id = id
		self.message = message
	}

	var description: String {
		"(\(id)-'\(message)')"
	}
}
