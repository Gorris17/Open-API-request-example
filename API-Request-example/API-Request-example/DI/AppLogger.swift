//
//  AppLogger.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import OSLog

/// Centralised logger namespace. One `Logger` per functional category.
/// Use via Instruments > Console or Xcode console (filter by subsystem).
enum AppLogger {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.alten.app"

    static let network     = Logger(subsystem: subsystem, category: "network")
    static let cache       = Logger(subsystem: subsystem, category: "cache")
    static let persistence = Logger(subsystem: subsystem, category: "persistence")
    static let search      = Logger(subsystem: subsystem, category: "search")
}
