//
//  RecentTrackEntityTests.swift
//  API-Request-exampleTests
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import Testing

@testable import API_Request_example

@MainActor
struct RecentTrackEntityTests {

    // MARK: - Helpers

    private func makeTrack(
        id: Int = 42,
        name: String = "Bohemian Rhapsody",
        artist: String = "Queen",
        album: String = "A Night at the Opera",
        artworkURL: URL? = URL(string: "https://example.com/art.jpg"),
        genre: String = "Rock",
        releaseYear: String = "1975",
        price: Double? = 1.29
    ) -> Track {
        Track(id: id, name: name, artist: artist, album: album,
              artworkURL: artworkURL, genre: genre, releaseYear: releaseYear, price: price)
    }

    // MARK: - Init

    @Test func storesAllFieldsFromTrack() {
        let track = makeTrack()
        let entity = RecentTrackEntity(track: track)

        #expect(entity.trackId == 42)
        #expect(entity.trackName == "Bohemian Rhapsody")
        #expect(entity.artistName == "Queen")
        #expect(entity.album == "A Night at the Opera")
        #expect(entity.artworkURLString == "https://example.com/art.jpg")
        #expect(entity.genre == "Rock")
        #expect(entity.releaseYear == "1975")
        #expect(entity.price == 1.29)
    }

    @Test func storesNilArtworkAsNil() {
        let entity = RecentTrackEntity(track: makeTrack(artworkURL: nil))
        #expect(entity.artworkURLString == nil)
    }

    @Test func storesNilPriceAsNil() {
        let entity = RecentTrackEntity(track: makeTrack(price: nil))
        #expect(entity.price == nil)
    }

    @Test func viewedAtIsSetToCurrentDateOnInit() {
        let before = Date()
        let entity = RecentTrackEntity(track: makeTrack())
        let after = Date()

        #expect(entity.viewedAt >= before)
        #expect(entity.viewedAt <= after)
    }

    // MARK: - toDomain

    @Test func toDomainMapsAllFields() {
        let track = makeTrack()
        let restored = RecentTrackEntity(track: track).toDomain()

        #expect(restored.id == track.id)
        #expect(restored.name == track.name)
        #expect(restored.artist == track.artist)
        #expect(restored.album == track.album)
        #expect(restored.artworkURL == track.artworkURL)
        #expect(restored.genre == track.genre)
        #expect(restored.releaseYear == track.releaseYear)
        #expect(restored.price == track.price)
    }

    @Test func toDomainHandlesNilArtworkURL() {
        let restored = RecentTrackEntity(track: makeTrack(artworkURL: nil)).toDomain()
        #expect(restored.artworkURL == nil)
    }

    @Test func toDomainHandlesNilPrice() {
        let restored = RecentTrackEntity(track: makeTrack(price: nil)).toDomain()
        #expect(restored.price == nil)
    }

    @Test func toDomainRoundTripsArtworkURL() {
        let url = URL(string: "https://example.com/art.jpg")
        let restored = RecentTrackEntity(track: makeTrack(artworkURL: url)).toDomain()
        #expect(restored.artworkURL == url)
    }
}
