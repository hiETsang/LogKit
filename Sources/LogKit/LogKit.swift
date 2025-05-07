import Foundation
import OSLog

/// LogKit - A lightweight and extensible logging framework for Swift
///
/// Examples:
/// ```
/// Log.debug("Debug message")
/// Log.info("Info message", category: .network)
/// Log.error("Error message", category: .database)
/// ```

// Core types
public typealias Log = Logger
public typealias LogFileManager = FileLogger
public typealias LogCategory = Logger.Category
public typealias LogLevel = Logger.LogLevel
public typealias LogHandler = Logger.LogHandler
