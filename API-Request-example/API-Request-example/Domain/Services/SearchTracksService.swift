//
//  SearchTracksService.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

protocol SearchTracksServiceProtocol {
    func execute(query: String) async throws -> [Track]
}

final class SearchTracksService: SearchTracksServiceProtocol {
    private let repository: TrackRepositoryProtocol

    init(repository: TrackRepositoryProtocol) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [Track] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await repository.search(query: trimmed)
    }
}
