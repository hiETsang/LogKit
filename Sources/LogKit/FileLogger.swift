import Foundation
import OSLog

/// File logger responsible for writing logs to files and managing log lifecycle
public final class FileLogger: Sendable {
    /// Log storage directory
    private let logDirectory: URL

    /// Date formatter for log files
    private let dateFormatter: DateFormatter

    /// Queue for file I/O operations
    private let ioQueue = DispatchQueue(label: "com.app.logkit.fileLogger", qos: .utility)

    /// Initialize file logger
    public init() {
        // Setup date formatter
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        // Setup log directory
        let fileManager = FileManager.default
        let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        logDirectory = documentsDirectory.appendingPathComponent("Logs", isDirectory: true)

        // Create log directory
        try? fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
    }

    /// Get URL for current day's log file
    private func getLogFileURL() -> URL {
        let dateString = dateFormatter.string(from: Date())
        return logDirectory.appendingPathComponent("log-\(dateString).txt")
    }

    /// Get emoji for log level
    /// - Parameter level: Log level
    /// - Returns: Corresponding emoji
    private func emojiForLevel(_ level: LogLevel) -> String {
        switch level {
        case .debug:
            return "🔍" // Debug
        case .info:
            return "ℹ️" // Info
        case .notice:
            return "📝" // Notice
        case .warning:
            return "⚠️" // Warning
        case .error:
            return "❌" // Error
        case .fault:
            return "🔥" // Critical error
        }
    }

    /// Write log to file
    /// - Parameters:
    ///   - level: Log level
    ///   - category: Log category
    ///   - message: Log message
    public func writeLog(level: LogLevel, category: String, message: String) async {
        // Get current time
        let currentTime = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss.SSS"
        let timeString = timeFormatter.string(from: currentTime)

        // Build log line with emoji
        let levelString = String(describing: level).uppercased()
        let emoji = emojiForLevel(level)
        let logLine = "[\(timeString)] \(emoji) [\(levelString)] [\(category)] \(message)\n"

        // Write to file asynchronously
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            self.ioQueue.async {
                let fileURL = self.getLogFileURL()
                do {
                    // Create file if it doesn't exist
                    if !FileManager.default.fileExists(atPath: fileURL.path) {
                        try "".write(to: fileURL, atomically: true, encoding: .utf8)
                    }

                    // Open file handle to append content
                    let fileHandle = try FileHandle(forWritingTo: fileURL)
                    fileHandle.seekToEndOfFile()

                    // Write log line
                    if let data = logLine.data(using: String.Encoding.utf8) {
                        fileHandle.write(data)
                    }

                    try fileHandle.close()
                } catch {
                    os_log(.error, "Failed to write log file: %{public}@", error.localizedDescription)
                }

                continuation.resume()
            }
        }
    }

    /// Clean up expired log files
    /// - Parameter days: Number of days to retain logs; older logs will be deleted
    public func cleanupExpiredLogs(olderThan days: Int) async {
        await withCheckedContinuation { continuation in
            self.ioQueue.async {
                let calendar = Calendar.current
                let cutoffDate = calendar.date(byAdding: .day, value: -days, to: Date())!

                do {
                    // Get all log files
                    let fileManager = FileManager.default
                    let fileURLs = try fileManager.contentsOfDirectory(at: self.logDirectory, includingPropertiesForKeys: [.creationDateKey], options: .skipsHiddenFiles)

                    // Delete old files
                    for fileURL in fileURLs {
                        if let attributes = try? fileManager.attributesOfItem(atPath: fileURL.path),
                           let creationDate = attributes[.creationDate] as? Date,
                           creationDate < cutoffDate
                        {
                            try fileManager.removeItem(at: fileURL)
                            os_log(.info, "Deleted expired log file: %{public}@", fileURL.lastPathComponent)
                        }
                    }
                } catch {
                    os_log(.error, "Failed to clean up log files: %{public}@", error.localizedDescription)
                }

                continuation.resume()
            }
        }
    }

    /// Get all log files
    /// - Returns: Array of log file URLs
    public func getAllLogFiles() async -> [URL] {
        return await withCheckedContinuation { continuation in
            self.ioQueue.async {
                do {
                    let fileManager = FileManager.default
                    let fileURLs = try fileManager.contentsOfDirectory(at: self.logDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
                    continuation.resume(returning: fileURLs.sorted { $0.lastPathComponent > $1.lastPathComponent })
                } catch {
                    os_log(.error, "Failed to get log file list: %{public}@", error.localizedDescription)
                    continuation.resume(returning: [])
                }
            }
        }
    }

    /// Read log file content
    /// - Parameter fileURL: Log file URL
    /// - Returns: Log content string, nil if reading fails
    public func readLogFile(at fileURL: URL) async -> String? {
        return await withCheckedContinuation { continuation in
            self.ioQueue.async {
                do {
                    let content = try String(contentsOf: fileURL, encoding: .utf8)
                    continuation.resume(returning: content)
                } catch {
                    os_log(.error, "Failed to read log file: %{public}@", error.localizedDescription)
                    continuation.resume(returning: nil)
                }
            }
        }
    }

    /// Delete all log files
    public func deleteAllLogs() async {
        await withCheckedContinuation { continuation in
            self.ioQueue.async {
                do {
                    let fileManager = FileManager.default
                    let fileURLs = try fileManager.contentsOfDirectory(at: self.logDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)

                    for fileURL in fileURLs {
                        try fileManager.removeItem(at: fileURL)
                    }

                    os_log(.info, "All log files deleted")
                } catch {
                    os_log(.error, "Failed to delete log files: %{public}@", error.localizedDescription)
                }

                continuation.resume()
            }
        }
    }
}
