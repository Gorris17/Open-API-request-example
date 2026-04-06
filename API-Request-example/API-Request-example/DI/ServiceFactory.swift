//
//  ServiceFactory.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

/// Centralised factory that exposes static singleton instances of every service.
/// Dependencies are wired once at first access (Swift static-let is lazily initialised).

enum ServiceFactory {
    static let apiService: APIServiceProtocol = APIService()

    // Stored as the concrete type so CacheManager can call purgeExpired().
    private static let concreteSearchCache = SearchCache()
    static let searchCache: SearchCacheProtocol = concreteSearchCache
    static let cacheManager: CacheManagerProtocol = CacheManager(cache: concreteSearchCache)

    static let trackRepository: TrackRepositoryProtocol = TrackRepository(
        apiService: apiService,
        cache: searchCache
    )

    static let searchTracksService: SearchTracksServiceProtocol = SearchTracksService(
        repository: trackRepository
    )
}
