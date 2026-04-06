//
//  CacheManager.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

protocol CacheManagerProtocol {
    func start()
    func stop()
}

/// Periodically purges expired entries from SearchCache.
/// Call `start()` when the app becomes active and `stop()` when it backgrounds.
final class CacheManager: CacheManagerProtocol {
    private let cache: SearchCache
    private let interval: TimeInterval
    private var task: Task<Void, Never>?

    /// - Parameters:
    ///   - cache: The cache instance to maintain.
    ///   - interval: Purge interval in seconds (default 5 minutes).
    init(cache: SearchCache, interval: TimeInterval = 5 * 60) {
        self.cache = cache
        self.interval = interval
    }

    func start() {
        guard task == nil else { return }
        AppLogger.cache.info("CacheManager started (purge interval: \(self.interval, privacy: .public)s)")
        task = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(interval))
                guard !Task.isCancelled else { return }
                AppLogger.cache.debug("CacheManager triggering purge")
                cache.purgeExpired()
            }
        }
    }

    func stop() {
        AppLogger.cache.info("CacheManager stopped")
        task?.cancel()
        task = nil
    }
}
