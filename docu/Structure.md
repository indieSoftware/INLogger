## Structure

This logger supports both, a log severity like `debug`, `info`, `warn`, `error` and `fatal` as well as tags which can be customized to mark message with those tags or to disable message on a top level.

For example, it's possible to provide tags for each feautre in the app and log a message with the corresponding tag in which feature the log has been dispatched. On the scope of the tag definition it's then easy to enable or disable all logs with that tag.

The logger consists of multiple components, each replaceable by custom implementations. The `Logger` instance itself is the interface for a developer to dispatch a log message. The `Logger` then processes the log message through the components.

### `LogEntryCreator`

The `LogEntryCreator` is the first component of a `Logger`. Its responsibility is to trasform the log message call together with some meta-information into a `LogEntry`. This happens immediately during the log message call on the same thread and, therefore, should be as fast as possible.

The `LogEntry` is then passed to a background thread for further processing by the logger's pipelines. The properties of such a log entry are fix, but one property named `additionalData` can be used to pass any time wished. Usually the default implementation `SimpleLogEntryCreator` should be enough because it collects all neceesary information for the formatter, but a custom implementation can use that `additionalData` property to pass more information for a custom formatter.

### `LogPipeline`

The `Logger` can be configured with different pipelines. A `LogEntry` will be passed to all pipelines so that each pipeline can process the log entry differently, i.e. one might show limited information to the console while another pipeline prints detailed information to a file. 

The pipelines are executed on a background thread, but sequentially. Each pipeline consists of multiple steps: filter, format and write.

### `LogFilter`

The first step of a pipeline is to determine whether a log entry should be further processed by the pipeline or not. This is done with a `LogFilter`.

There are already some pre-defined filters provided which should work for the majority of all projects. However, if more advanced filtering is necessary then simply implement the `LogFilter` protocol and implement a custom filter.

### `LogFormatter`

When the filter decided to process a log entry then the second step of a pipeline will format that log entry into a string for output. Depending of the format this step might be a little bit time consuming, especially when date formatters are consulted, but also the string manipulation might be complex. The result is a formatted string which will then be passed to the pipeline's writers.

Some example formatters are already provided ready to be used out-of-the-box. However, it's highly likely that a custom formatter needs to be written to format the log messages in a way suitable of the project's needs. This can be easily done by implementing the `LogFormatter` protocol and pass an instance to the logger's pipeline.

### `LogWriter`

The last step of a pipeline is to write the formatted log message somewhere, e.g. to the console or a file. Each pipeline can consist of multiple writers. That allows to re-use the same formatted string but print it to two different places. However, if the log message should differ for each write location then multiple pipelines has to be used.

There exist default writers for writing to the console or to a file. However, if a different write location is needed, for example to a remote resource, then simply implement a custom writer solution.
