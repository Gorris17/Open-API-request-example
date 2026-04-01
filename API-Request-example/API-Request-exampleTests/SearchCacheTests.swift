//
//  SearchCacheTests.swift
//  API-Request-exampleTests
//
//  Created by Fernando Corral on 1/4/26.
//

import Testing
@testable import API_Request_example

struct SearchCacheTests {

    private func makeTrack(id: Int = 1) -> Track {
        Track(id: id, name: "Track \(id)", artist: "Artist", album: "Album",
              artworkURL: nil, genre: "Pop", releaseYear: "2024", price: nil)
    }

    @Test func returnsNilWhenEmpty() {
        let cache = SearchCache()
        #expect(cache.get(for: "swift") == nil)
    }

    @Test func returnsCachedResult() {
        let cache = SearchCache()
        let track = makeTrack()
        cache.set([track], for: "swift")

        let result = cache.get(for: "swift")
        #expect(result?.count == 1)
        #expect(result?.first?.id == 1)
    }

    @Test func cacheIsCaseInsensitive() {
        let cache = SearchCache()
        cache.set([makeTrack()], for: "SWIFT")
        #expect(cache.get(for: "swift") != nil)
        #expect(cache.get(for: "Swift") != nil)
    }

    @Test func expiredEntryReturnsNil() async throws {
        let cache = SearchCache(ttl: 0.05) // 50 ms TTL
        cache.set([makeTrack()], for: "swift")
        try await Task.sleep(for: .milliseconds(100))
        #expect(cache.get(for: "swift") == nil)
    }

    @Test func freshEntryIsStillValid() async throws {
        let cache = SearchCache(ttl: 60)
        cache.set([makeTrack()], for: "swift")
        try await Task.sleep(for: .milliseconds(50))
        #expect(cache.get(for: "swift") != nil)
    }

    @Test func overwritesPreviousEntry() {
        let cache = SearchCache()
        cache.set([makeTrack(id: 1)], for: "queen")
        cache.set([makeTrack(id: 2), makeTrack(id: 3)], for: "queen")

        let result = cache.get(for: "queen")
        #expect(result?.count == 2)
        #expect(result?.first?.id == 2)
    }
}
