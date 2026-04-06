//
//  AppLogger.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import OSLog

/// Centralised logging facade. OSLog is imported only here.
/// Call sites use plain Swift string interpolation — no `import OSLog` needed.
enum AppLogger {
    enum Category {
        case network, cache, persistence, search
    }

    static func debug(_ message: String, _ category: Category) {
        logger(for: category).debug("\(message, privacy: .public)")
    }

    static func info(_ message: String, _ category: Category) {
        logger(for: category).info("\(message, privacy: .public)")
    }

    static func error(_ message: String, _ category: Category) {
        logger(for: category).error("\(message, privacy: .public)")
    }

    // MARK: - Private

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.alten.app"

    private static let networkLogger     = Logger(subsystem: subsystem, category: "network")
    private static let cacheLogger       = Logger(subsystem: subsystem, category: "cache")
    private static let persistenceLogger = Logger(subsystem: subsystem, category: "persistence")
    private static let searchLogger      = Logger(subsystem: subsystem, category: "search")

    private static func logger(for category: Category) -> Logger {
        switch category {
        case .network:     return networkLogger
        case .cache:       return cacheLogger
        case .persistence: return persistenceLogger
        case .search:      return searchLogger
        }
    }
}
