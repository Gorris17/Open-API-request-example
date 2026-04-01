//
//  SearchTracksUseCase.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

protocol SearchTracksUseCaseProtocol {
    func execute(query: String) async throws -> [Track]
}

final class SearchTracksUseCase: SearchTracksUseCaseProtocol {
    private let repository: TrackRepository

    init(repository: TrackRepository) {
        self.repository = repository
    }

    func execute(query: String) async throws -> [Track] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        return try await repository.search(query: trimmed)
    }
}
