//
//  TrackRepositoryImpl.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

/// Concrete implementation of TrackRepository.
/// Checks the in-memory cache first; falls back to the iTunes API on a miss.
final class TrackRepositoryImpl: TrackRepository {
    private let apiService: APIServiceProtocol
    private let cache: SearchCacheProtocol

    init(apiService: APIServiceProtocol, cache: SearchCacheProtocol) {
        self.apiService = apiService
        self.cache = cache
    }

    func search(query: String) async throws -> [Track] {
        if let cached = cache.get(for: query) {
            return cached
        }

        let response: SearchResponsePOSO = try await apiService.request(
            ITunesEndpoint.search(query: query)
        )

        let tracks = response.results.compactMap { $0.toDomain() }
        cache.set(tracks, for: query)
        return tracks
    }
}
