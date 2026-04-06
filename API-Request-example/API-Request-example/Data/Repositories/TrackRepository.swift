//
//  TrackRepository.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

/// Concrete implementation of TrackRepositoryProtocol.
/// Checks the in-memory cache first; falls back to the iTunes API on a miss.
final class TrackRepository: TrackRepositoryProtocol {
    private let apiService: APIServiceProtocol
    private let cache: SearchCacheProtocol

    init(apiService: APIServiceProtocol, cache: SearchCacheProtocol) {
        self.apiService = apiService
        self.cache = cache
    }

    func search(query: String) async throws -> [Track] {
        if let cached = cache.get(for: query) {
            AppLogger.cache.debug("Cache hit for '\(query, privacy: .private)' → \(cached.count, privacy: .public) tracks")
            return cached
        }

        AppLogger.cache.debug("Cache miss for '\(query, privacy: .private)', fetching from API")
        let response: SearchResponsePOSO = try await apiService.request(
            ITunesEndpoint.search(query: query)
        )

        let tracks = response.results.compactMap { $0.toDomain() }
        AppLogger.cache.debug("Storing \(tracks.count, privacy: .public) tracks in cache for '\(query, privacy: .private)'")
        cache.set(tracks, for: query)
        return tracks
    }
}
