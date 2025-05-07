import Foundation
import OSLog

/// Core logger
public class Logger {
    /// Shared instance
    public static let shared = Logger()

    /// Minimum log level - logs below this level won't be recorded
    public var minimumLogLevel: LogLevel = .debug

    /// Whether to save logs to file
    public var saveToFile: Bool = true

    /// Whether to show detailed info (filename, line number, function name)
    public var showDetails: Bool = false

    /// Number of days to retain log files
    public var retentionDays: Int = 7

    /// File logger instance
    public let fileLogger = FileLogger()

    /// Additional log handlers
    private var logHandlers: [LogHandler] = []

    private init() {
        // Clean up expired logs
        cleanupExpiredLogs()
    }

    /// Register a log handler
    /// - Parameter handler: Handler implementing the LogHandler protocol
    public func registerLogHandler(_ handler: LogHandler) {
        logHandlers.append(handler)
    }

    /// Remove a log handler
    /// - Parameter handler: Handler to remove (matched by reference)
    public func removeLogHandler(_ handler: LogHandler) {
        logHandlers.removeAll(where: { $0 as AnyObject === handler as AnyObject })
    }

    /// Get OS logger for a specific category
    private func getOSLogger(subsystem: String, category: String) -> os.Logger {
        return os.Logger(subsystem: subsystem, category: category)
    }

    /// Clean up expired logs
    private func cleanupExpiredLogs() {
        Task {
            await fileLogger.cleanupExpiredLogs(olderThan: retentionDays)
        }
    }

    // MARK: - Logging methods

    /// Log debug message
    public func debug(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Log info message
    public func info(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Log notice message
    public func notice(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .notice, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Log warning message
    public func warning(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Log error message
    public func error(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Log critical error message
    public func fault(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        log(level: .fault, message: message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Core logging method
    private func log(level: LogLevel, message: String, category: String, subsystem: String, file: String, function: String, line: Int) {
        // Check if log level meets minimum requirement
        guard level >= minimumLogLevel else { return }

        // Get OSLogger
        let osLogger = getOSLogger(subsystem: subsystem, category: category)

        // Build log message
        let fileName = (file as NSString).lastPathComponent
        let logMessage = showDetails ? "[\(fileName):\(line) \(function)] \(message)" : message

        // Use appropriate OSLog method based on log level
        switch level {
        case .debug:
            osLogger.debug("\(logMessage, privacy: .public)")
        case .info:
            osLogger.info("\(logMessage, privacy: .public)")
        case .notice:
            osLogger.notice("\(logMessage, privacy: .public)")
        case .warning:
            osLogger.warning("\(logMessage, privacy: .public)")
        case .error:
            osLogger.error("\(logMessage, privacy: .public)")
        case .fault:
            osLogger.fault("\(logMessage, privacy: .public)")
        }

        // Save to file
        if saveToFile {
            Task {
                await fileLogger.writeLog(level: level, category: category, message: logMessage)
            }
        }

        // Call all registered log handlers
        for handler in logHandlers {
            handler.handleLog(level: level, message: logMessage, category: category)
        }
    }

    // MARK: - Static convenience methods

    /// Static debug log method
    public static func debug(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.debug(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Static info log method
    public static func info(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.info(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Static notice log method
    public static func notice(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.notice(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Static warning log method
    public static func warning(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.warning(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Static error log method
    public static func error(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.error(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }

    /// Static critical error log method
    public static func fault(_ message: String, category: String = Logger.Category.general, subsystem: String = Bundle.main.bundleIdentifier ?? "com.app.logkit", file: String = #file, function: String = #function, line: Int = #line) {
        shared.fault(message, category: category, subsystem: subsystem, file: file, function: function, line: line)
    }
}

/// Log categories with string constants (extensible via extensions)
public extension Logger {
    enum Category {
        public static let general = "general"
        public static let network = "network"
        public static let database = "database"
    }
}

/// Log levels
public extension Logger {
    enum LogLevel: Int, Comparable {
        case debug = 0
        case info = 1
        case notice = 2
        case warning = 3
        case error = 4
        case fault = 5

        public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
            return lhs.rawValue < rhs.rawValue
        }
    }
}

/// Log handler protocol
public extension Logger {
    protocol LogHandler {
        /// Handle log message
        /// - Parameters:
        ///   - level: Log level
        ///   - message: Log message
        ///   - category: Log category
        func handleLog(level: LogLevel, message: String, category: String)
    }
}
