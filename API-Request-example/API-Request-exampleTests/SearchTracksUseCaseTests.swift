//
//  SearchTracksUseCaseTests.swift
//  API-Request-exampleTests
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import Testing
@testable import API_Request_example

struct SearchTracksUseCaseTests {

    // MARK: - Helpers

    private func makeTrack(id: Int = 1, name: String = "Song") -> Track {
        Track(id: id, name: name, artist: "Artist", album: "Album",
              artworkURL: nil, genre: "Pop", releaseYear: "2024", price: nil)
    }

    private func makeSUT(repository: MockTrackRepository) -> SearchTracksService {
        SearchTracksService(repository: repository)
    }

    // MARK: - Tests

    @Test func returnsEmptyArrayForBlankQuery() async throws {
        let repo = MockTrackRepository()
        let sut  = makeSUT(repository: repo)

        let result = try await sut.execute(query: "   ")
        #expect(result.isEmpty)
        #expect(repo.searchCallCount == 0)
    }

    @Test func returnsEmptyArrayForEmptyQuery() async throws {
        let repo = MockTrackRepository()
        let sut  = makeSUT(repository: repo)

        let result = try await sut.execute(query: "")
        #expect(result.isEmpty)
        #expect(repo.searchCallCount == 0)
    }

    @Test func delegatesNonEmptyQueryToRepository() async throws {
        let repo = MockTrackRepository(stubbedTracks: [makeTrack()])
        let sut  = makeSUT(repository: repo)

        let result = try await sut.execute(query: "queen")
        #expect(result.count == 1)
        #expect(repo.searchCallCount == 1)
    }

    @Test func trimsWhitespaceBeforeForwardingQuery() async throws {
        let repo = MockTrackRepository()
        let sut  = makeSUT(repository: repo)

        _ = try await sut.execute(query: "  bohemian  ")
        #expect(repo.lastQuery == "bohemian")
    }

    @Test func propagatesRepositoryError() async throws {
        let repo = MockTrackRepository(stubbedError: URLError(.notConnectedToInternet))
        let sut  = makeSUT(repository: repo)

        await #expect(throws: URLError.self) {
            _ = try await sut.execute(query: "queen")
        }
    }

    @Test func returnsAllTracksFromRepository() async throws {
        let tracks = (1...5).map { makeTrack(id: $0) }
        let repo   = MockTrackRepository(stubbedTracks: tracks)
        let sut    = makeSUT(repository: repo)

        let result = try await sut.execute(query: "rock")
        #expect(result.count == 5)
    }
}

// MARK: - Mock

final class MockTrackRepository: TrackRepositoryProtocol {
    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?

    private let stubbedTracks: [Track]
    private let stubbedError: Error?

    init(stubbedTracks: [Track] = [], stubbedError: Error? = nil) {
        self.stubbedTracks = stubbedTracks
        self.stubbedError  = stubbedError
    }

    func search(query: String) async throws -> [Track] {
        searchCallCount += 1
        lastQuery = query
        if let error = stubbedError { throw error }
        return stubbedTracks
    }
}
