# LogKit

**LogKit** is a modern, modular, and extensible Swift logging library designed for Swift/iOS projects. It supports Swift Package Manager and is suitable for any app or framework that needs efficient log management.

---

## ✨ Philosophy

- **Modular**: Decoupled design, easy to integrate into any project.
- **Type-safe**: Strongly typed log levels, flexible and extensible log categories.
- **Easy to use**: Intuitive API, supports singleton and static method calls.
- **High performance**: Asynchronous writing, file logging support, automatic log file cleanup.
- **Extensible**: Custom log handlers and categories, adaptable to various business scenarios.
- **SOLID Principles**: Single responsibility, open/closed, dependency inversion, and other best practices.

---

## 📦 Installation

Recommended: [Swift Package Manager](https://developer.apple.com/documentation/swift_packages):

```swift
.package(url: "https://github.com/hiETsang/LogKit.git", from: "1.0.0")
```

---

## 🏗️ Architecture & Core Concepts

### Log Levels

Six built-in log levels, type-safe, covering all common scenarios:

- `.debug`   Debug information
- `.info`    General information
- `.notice`  Notice
- `.warning` Warning
- `.error`   Error
- `.fault`   Critical error

### Log Categories

- Use static constants + extension, **fully customizable** by consumers, with type safety and autocompletion.
- Common categories are built-in; you can extend your own via `extension Logger.Category`.

### File Logging

- Logs can be written to local files asynchronously, with automatic cleanup of expired logs.
- Log files are split by day for easy archiving and export.

### Log Handlers

- Support for custom log handlers (`LogHandler`), enabling log reporting, third-party integration, etc.

---

## 🚀 Quick Start

### 1. Basic Usage

```swift
import LogKit

// Simplified API (recommended)
Log.debug("Debug info")
Log.info("General info", category: .network)
Log.error("An error occurred", category: .database)

// Alternative ways
Logger.shared.debug("Debug info")
Logger.info("General info", category: .network)
```

### 2. Custom Log Categories

```swift
extension Logger.Category {
    public static let payment = "payment"
    public static let onboarding = "onboarding"
}

Log.info("Payment succeeded", category: .payment)
```

### 3. Static Method Calls

```swift
// Simplified API
Log.debug("Static debug log")
Log.error("Static error log", category: .database)

// Alternative
Logger.debug("Static debug log")
```

### 4. File Log Management

- Logs are written to local files by default (configurable).
- Expired logs are automatically cleaned up (default retention: 7 days).

---

## ⚙️ Configuration & Advanced Usage

### Set Minimum Log Level

```swift
Logger.shared.minimumLogLevel = .info // Only logs info and above
```

### Disable File Logging

```swift
Logger.shared.saveToFile = false
```

### Show Details (filename, line, function)

```swift
Logger.shared.showDetails = true
```

### Custom Log Handler

```swift
struct MyHandler: LogHandler {
    func handleLog(level: LogLevel, message: String, category: String) {
        // Send to third-party platform
    }
}

Logger.shared.registerLogHandler(MyHandler())
```

---

## 🧩 Extensions & Best Practices

- **Custom Categories**: Use `extension Logger.Category` to manage categories, avoid hardcoded strings.
- **Modular Logging**: Define a category for each business module for easy filtering and analysis.
- **Log Export**: Use FileLogger to fetch/export log files for troubleshooting.

---

## 🛡️ Security & Performance

- Asynchronous log writing for high performance.
- Automatic log file cleanup to save storage.
- Only critical logs are written to file, avoid leaking sensitive data.

---

## 📝 Contributing & Feedback

Issues, PRs, and suggestions are welcome!
For custom features or enterprise support, please contact the author.

---

## 📄 License

MIT License 
