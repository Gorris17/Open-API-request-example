//
//  SearchViewModelTests.swift
//  API-Request-exampleTests
//
//  Created by Fernando Corral on 1/4/26.
//

import Testing
@testable import API_Request_example

@MainActor
struct SearchViewModelTests {

    // MARK: - Helpers

    private func makeTrack(id: Int = 1) -> Track {
        Track(id: id, name: "Song \(id)", artist: "Artist", album: "Album",
              artworkURL: nil, genre: "Pop", releaseYear: "2024", price: nil)
    }

    private func makeSUT(repo: MockTrackRepository) -> SearchViewModel {
        SearchViewModel(searchUseCase: SearchTracksService(repository: repo))
    }

    // MARK: - Debounce

    @Test @MainActor func debounceIgnoresIntermediateKeystrokes() async throws {
        let repo = MockTrackRepository(stubbedTracks: [makeTrack()])
        let sut = makeSUT(repo: repo)

        // Simulate rapid typing — each call cancels the previous task
        sut.searchText = "b";     sut.search()
        sut.searchText = "br";    sut.search()
        sut.searchText = "bri";   sut.search()
        sut.searchText = "bring"; sut.search()

        // Wait past the 300ms debounce window
        try await Task.sleep(for: .milliseconds(450))

        #expect(repo.searchCallCount == 1)
        #expect(repo.lastQuery == "bring")
    }

    @Test @MainActor func searchFiresOnceAfterDebounceWindow() async throws {
        let repo = MockTrackRepository(stubbedTracks: [makeTrack()])
        let sut = makeSUT(repo: repo)

        sut.searchText = "queen"
        sut.search()

        try await Task.sleep(for: .milliseconds(450))

        #expect(repo.searchCallCount == 1)
        #expect(sut.tracks.count == 1)
    }

    @Test @MainActor func emptyQueryDoesNotSearch() async throws {
        let repo = MockTrackRepository(stubbedTracks: [makeTrack()])
        let sut = makeSUT(repo: repo)

        sut.searchText = "   "
        sut.search()

        try await Task.sleep(for: .milliseconds(450))

        #expect(repo.searchCallCount == 0)
        #expect(sut.tracks.isEmpty)
    }
}
