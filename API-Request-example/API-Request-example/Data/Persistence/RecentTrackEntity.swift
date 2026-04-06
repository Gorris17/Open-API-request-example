//
//  RecentTrackEntity.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import SwiftData

/// SwiftData persistent model storing recently viewed tracks with full detail.
@Model
final class RecentTrackEntity {
    var trackId: Int
    var trackName: String
    var artistName: String
    var album: String
    var artworkURLString: String?
    var genre: String
    var releaseYear: String
    var price: Double?
    var viewedAt: Date

    init(track: Track) {
        self.trackId = track.id
        self.trackName = track.name
        self.artistName = track.artist
        self.album = track.album
        self.artworkURLString = track.artworkURL?.absoluteString
        self.genre = track.genre
        self.releaseYear = track.releaseYear
        self.price = track.price
        self.viewedAt = Date()
    }

    func toDomain() -> Track {
        Track(
            id: trackId,
            name: trackName,
            artist: artistName,
            album: album,
            artworkURL: artworkURLString.flatMap { URL(string: $0) },
            genre: genre,
            releaseYear: releaseYear,
            price: price
        )
    }
}
