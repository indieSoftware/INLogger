## Usage

### Setting up the logger

Either instantiate a `Logger` instance to inject it through the whole code via a dependency manager or simply assign it to the `Logger.shared` property to have a global accessor.

There are two ways to log messages through the logger, via the instance methods or via the static methods. 

```
let logger: Logger = ...
logger.debug("A log message via an instance method")

Logger.debug("A log message via a static method")
```

Both are doing the same and the static methods are calling the instance methods of the `shared` instance. Therefore, when using the static methods make sure the global logger instance has been assigned to the static `shared` property before.

```
Logger.shared = Logger(...)
```

If not doing so then the default shared instance will be used which doesn't log anything.

```
// A logger which doesn't log anything
Logger(entryCreator: SimpleLogEntryCreator(), pipelines: [])
```

In the initializer of the `Logger` instance a `LogEntryCreator` and any number of `LogPipeline`s has to be passed to. For the `LogEntryCreator` usually an instance of `SimpleLogEntryCreator` should be enough and can be passed. However, if additional information need to be gathered for the formatter, e.g. the thread's number to print the thread's number along with each log message, then a custom `LogEntryCreator` can be created instead.

### Setting up a pipeline

When not passing any pipelines at all then nothing will be processed by the logger instance and thus nothing will be logged. Therefore, ususally at least one instance of `LogPipeline` should be passed.

```
// A logger which prints unformatted log messages to the console
let consoleLogPipeline = LogPipeline(
	filter: DevelopmentLogFilter(),
	formatter: SimpleLogFormatter(),
	writer: [ConsoleLogWriter()]
)
Logger.shared = Logger(
	entryCreator: SimpleLogEntryCreator(),
	pipelines: [consoleLogPipeline]
)
```

By using different combinations of filters, formatters and writers it's possible to configure the logger. And when the provided filters, formatters and writers are not enough then it's possible to create own filters, formatters and writers by simply implementing the provided protocols.

### The filters

A filter implements the `LogFilter` protocol. A filter has to decide if a log message should be further processed by the pipeline and thus formatted and finally written somewhere or if it can simply be ignored and thus not logged anywhere.

There exists already two pre-defined filters: `DevelopmentLogFilter` and `ReleaseLogFilter`.

The `DevelopmentLogFilter` does not filter out any logs depending on the severity, that means even `debug` log messages are passing this filter. However, the tag state is respected, that means when at least one tag is `forceDisabled` then the message won't be logged regardless of the log's level. When all tags are `disabled` then `debug` and `info` logs also won't be logged. Log messages with the severity `warn`, `error` and `fatal` are, therefore, logged even when the tag's state is not set to `enabled` to make sure the developer is still aware about such logged problems.

The `ReleaseLogFilter` on the other hand doesn't take any tags into count, but the severity instead. That means `debug` messages are never passing the filter, but all others will regardless of the tag's state. That's usually the desired way because debug statements are only meant to be seen during development, but not in a release build. However, no other log statement should be filtered out even when the tag is disabled because usually everything should be logged to log files. However, if this is not the desired behavior then simply implement an own filter. 

It's highly likely that it's wished to use different pipelines for development and for a release build. For example, during development it's often enough to simply log to the console while in a release build any message should be logged to a file instead and with more information. In that case simply provide different instantion configurations of the `Logger` during app start depending on the build configuration.

```
#if DEBUG
	Logger.shared = createDevelopLogger()
#else
	Logger.shared = createReleaseLogger()
#endif
```

### The formatter

A formatter implements the `LogFormatter` protocol. A formatter takes the log entry from the `LogEntryCreator` and creates a formatted log message out of it. This usualy includes writing the log's date and source into a string together with the original message.

There are already 3 formatters provided, but it's highly likely that a new custom one will be needed to create. It's easy to provide a custom formatter, simply implement the `LogFormatter` protocol and inject an instance to the pipeline. Alternatively go with one of the pre-defined.

The simplest formatter implementation is the `SimpleLogFormatter`. It just returns the log message as the formatted string, essentially passing it through without really applying any formatting. This can be considered as a simple print replacement.

A common formatter, however, is the `DevelopLogFormatter`. This formatter not only prints the message, but also the severity with some nice emojis, the tag's abbreviation icon, the log's file and line. Usually this is enough to be printed to the console during development in a nice and appealing way without cluttering the console with too many information which are not really necessary.

The last pre-defined formatter is the `FileLogFormatter`. This one does not show any severity emojis, but some letters. It also prints the log's date and time next to the method's name into the final formatted string. This formatter is mostly suitable for writing the string finally to a file rather to the console because the formatted log statements will take some more space.

### The writer

The protocol of a writer is the `LogWriter`. Any implementation has to write the formatted message to a desired place.

The `ConsoleLogWriter` simply writes the formatted log message to the console via `print` statements. This is usually used during development.

The `FileLogWriter` writes the formatted log messages to a file. On each creation of an instance the log file will be rotated to a backup version. That way on each app start the old log file will be backed up and can be send to user support when a crash has occurred while the current log file can be send when the user wants to report a bug.

The `FileLogWriter` is kind of limited with only one backup file. Theoretically this can lead to an infinitve growing log file. Therefore, if a more robust or individual solution is needed here, just implement the `LogWriter` protocol and implement a custom solution for it.

### Log Tags

Tags are optional, but a helpful addition to group logs and filter them if needed. 

The library comes with the structure of tags, but with no pre-defined tags. That means, to use the tag system some tags have to be defined first. Do this by extending the the `LogTag` struct with some constants:

```
extension LogTag {
	static let unitTest = LogTag(state: .forceDisabled, name: "UnitTest", abbreviation: "🐞")
	static let uiTest = LogTag(state: .enabled, name: "UITest", abbreviation: "🤖")

	static let breadcrumb = LogTag(state: .enabled, name: "Breadcrumb", abbreviation: "🍞")
	static let general = LogTag(state: .enabled, name: "General", abbreviation: "⭐️")
	static let myFeature = LogTag(state: .disabled, name: "MyFeature", abbreviation: "💝")
}
```

The defined tags can then be used along with each log statement to tag the message.

```
Logger.debug("A general log message", tag: .general)
Logger.debug("A multi-tag log message", tags: [.breadcrumb, .myFeature])
```

Usually tags are used to associate log statements to features. For example, a log message in a screen of a feature should be marked with the corresponding tag, e.g. `myFeature`. When this feature is currently not under development then a developer usually is not interested in logs of that feature and to prevent to clutter the console with such non-relevant logs the whole tag can be marked as `disabled` to prevent such tagged logs to be logged.

It's possible to associate a log statement with multiple tags, i.e. when a message is not only part of a feature, but should also be marked as a breadcrumb. Breadcrumbs are user-initated actions which can be followed to trace bugs. For example, when a user complains about a bug then a developer can follow all breadcrumbs to see which actions the particular user has done to reproduce the behavior.

Whether a log statement is logged or not, whether a tag is taken into consideration for that or not, that's defined in the corresponding implementation of the `LogFilter`.
