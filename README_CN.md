# LogKit

**LogKit** 是一个现代化、模块化、可扩展的 Swift 日志库，专为 Swift/iOS 项目设计，支持 Swift Package Manager，适用于所有需要高效日志管理的 App 和框架。

---

## ✨ 设计理念

- **模块化**：解耦设计，易于集成到任何项目。
- **类型安全**：日志级别强类型，日志分类灵活可扩展。
- **易用性**：API 直观，支持单例调用和静态方法。
- **高性能**：异步写入，支持文件日志，自动清理过期日志。
- **可扩展**：支持自定义日志处理器和日志分类，适配多种业务场景。
- **符合 SOLID 原则**：单一职责、开放封闭、依赖倒置等最佳实践。

---

## 📦 安装

推荐使用 [Swift Package Manager](https://developer.apple.com/documentation/swift_packages)：

```swift
.package(url: "https://github.com/hiETsang/LogKit.git", from: "1.0.0")
```

---

## 🏗️ 架构与核心概念

### 日志级别

内置六种日志级别，类型安全，覆盖所有常见场景：

- `.debug`   调试信息
- `.info`    一般信息
- `.notice`  需要注意
- `.warning` 警告
- `.error`   错误
- `.fault`   严重错误

### 日志分类（Category）

- 采用静态常量 + 扩展方式，**支持外部自定义**，类型安全且自动补全。
- 默认内置常用分类，外部可通过 `extension Logger.Category` 扩展自定义。

### 文件日志

- 日志可自动写入本地文件，支持异步写入和过期清理。
- 日志文件按天分割，便于归档和导出。

### 日志处理器

- 支持自定义日志处理器（LogHandler），可扩展日志上报、第三方平台集成等。

---

## 🚀 快速上手

### 1. 基本用法

```swift
import LogKit

Logger.shared.debug("调试信息")
Logger.shared.info("普通信息", category: .network)
Logger.shared.error("发生错误", category: .database)
```

### 2. 自定义日志分类

```swift
extension Logger.Category {
    public static let payment = "payment"
    public static let onboarding = "onboarding"
}

Logger.shared.info("支付成功", category: .payment)
```

### 3. 静态方法调用

```swift
Logger.debug("静态调试日志")
Logger.error("静态错误日志", category: .database)
```

### 4. 文件日志管理

- 日志默认会写入本地文件（可配置）。
- 支持自动清理过期日志（默认保留 7 天）。

---

## ⚙️ 配置与高级用法

### 配置日志级别

```swift
Logger.shared.minimumLogLevel = .info // 只记录 info 及以上级别日志
```

### 关闭文件日志

```swift
Logger.shared.saveToFile = false
```

### 显示详细信息（文件名、行号、方法名）

```swift
Logger.shared.showDetails = true
```

### 自定义日志处理器

```swift
struct MyHandler: LogHandler {
    func handleLog(level: LogLevel, message: String, category: String) {
        // 发送到第三方平台
    }
}

Logger.shared.registerLogHandler(MyHandler())
```

---

## 🧩 扩展与最佳实践

- **自定义日志分类**：推荐通过 `extension Logger.Category` 统一管理，避免硬编码字符串。
- **模块化日志**：为每个业务模块定义独立 category，便于筛选和分析。
- **日志导出**：可通过 FileLogger 获取、导出日志文件，便于问题排查。

---

## 🛡️ 安全与性能

- 日志异步写入，性能无忧。
- 日志文件自动清理，节省存储空间。
- 仅关键日志写入文件，避免敏感信息泄露。

---

## 📝 贡献与反馈

欢迎 issue、PR 及建议！  
如需定制化功能或企业支持，请联系作者。

---

## 📄 License

MIT License 
