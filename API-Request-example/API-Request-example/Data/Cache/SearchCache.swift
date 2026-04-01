//
//  SearchCache.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

protocol SearchCacheProtocol {
    func get(for query: String) -> [Track]?
    func set(_ tracks: [Track], for query: String)
}

/// In-memory TTL cache keyed by lowercased search query.
final class SearchCache: SearchCacheProtocol {
    private struct Entry {
        let tracks: [Track]
        let expiresAt: Date
    }

    private var store: [String: Entry] = [:]
    private let ttl: TimeInterval

    /// - Parameter ttl: Time-to-live in seconds (default 3 minutes).
    init(ttl: TimeInterval = 3 * 60) {
        self.ttl = ttl
    }

    func get(for query: String) -> [Track]? {
        let key = query.lowercased()
        guard let entry = store[key] else { return nil }
        guard entry.expiresAt > Date() else {
            store.removeValue(forKey: key)
            return nil
        }
        return entry.tracks
    }

    func set(_ tracks: [Track], for query: String) {
        let entry = Entry(tracks: tracks, expiresAt: Date().addingTimeInterval(ttl))
        store[query.lowercased()] = entry
    }
}
