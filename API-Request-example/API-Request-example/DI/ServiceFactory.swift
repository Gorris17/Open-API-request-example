//
//  ServiceFactory.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

/// Centralised factory that exposes static singleton instances of every service.
/// Dependencies are wired once at first access (Swift static-let is lazily initialised).
///
/// Dependency graph (bottom → top):
///   APIService + SearchCache → TrackRepositoryImpl → SearchTracksUseCase
enum ServiceFactory {
    static let apiService: APIServiceProtocol = APIService()

    static let searchCache: SearchCacheProtocol = SearchCache()

    static let trackRepository: TrackRepository = TrackRepositoryImpl(
        apiService: apiService,
        cache: searchCache
    )

    static let searchTracksUseCase: SearchTracksUseCaseProtocol = SearchTracksUseCase(
        repository: trackRepository
    )
}
