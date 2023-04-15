![iOS Version](https://img.shields.io/badge/iOS-16.0+-brightgreen) [![Documentation Coverage](https://indiesoftware.github.io/INLogger/badge.svg)](https://indiesoftware.github.io/INLogger)
[![License](https://img.shields.io/github/license/indieSoftware/INLogger)](https://github.com/indieSoftware/INCommons/blob/master/LICENSE)
[![GitHub Tag](https://img.shields.io/github/v/tag/indieSoftware/INLogger?label=version)](https://github.com/indieSoftware/INLogger)
[![SPM compatible](https://img.shields.io/badge/SPM-compatible-success.svg)](https://github.com/apple/swift-package-manager)

[GitHub Page](https://github.com/indieSoftware/INLogger)

[Documentation](https://indiesoftware.github.io/INLogger)

# INLogger

A configurable logger.
 
## Overview

Create a logger and configure its behavior with pipelines by using different filter, formatter and writer.

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

Use the shared logger to log any log messages in code with one of the common severities:

```
Logger.debug("A debug message")
Logger.info("An info message")
Logger.warn("A warning message")
Logger.error("An error message")
Logger.fatal("A fatal error message")
```

Define custom tags and use them to tag log messages for easier following or enabling/disabling log messages on a tag level.

```
extension LogTag {
	static let breadcrumb = LogTag(state: .enabled, name: "Breadcrumb", abbreviation: "🍞")
	static let general = LogTag(state: .enabled, name: "General", abbreviation: "⭐️")
	static let myFeature = LogTag(state: .disabled, name: "MyFeature", abbreviation: "💝")
}

Logger.debug("A general log message", tag: .general)
Logger.debug("A multi-tag log message", tags: [.breadcrumb, .myFeature])
```

Implement own custom filters, formatters and writers to customzie the logging behavior according to the project's needs and to get beatiful and helpful log messages.

```
2022-10-14 09:39:57 INLoggerExample 💬🍞💝 [ExampleViewModel.swift:45] - A log message
```

## Installation

### SPM

To include via [SwiftPackageManager](https://swift.org/package-manager) add the repository:

```
https://github.com/indieSoftware/INLogger.git
```

## Structure

A description of INLogger's structure: [Structure](https://github.com/indieSoftware/INLogger/blob/master/docu/Structure.md)

## Usage

How to use INLogger: [Usage](https://github.com/indieSoftware/INLogger/blob/master/docu/Usage.md)

## Changelog

See [Changelog](https://github.com/indieSoftware/INNavigation/blob/master/Changelog.md) 

