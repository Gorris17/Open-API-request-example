//
//  TrackPOSO.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

/// Plain Old Swift Object – raw Decodable DTO from iTunes Search API.
struct TrackPOSO: Decodable {
    let trackId: Int
    let trackName: String?
    let artistName: String?
    let collectionName: String?
    let artworkUrl100: String?
    let primaryGenreName: String?
    let releaseDate: String?
    let trackPrice: Double?
}

// MARK: - Domain mapping

extension TrackPOSO {
    func toDomain() -> Track? {
        guard let name = trackName, let artist = artistName else { return nil }
        return Track(
            id: trackId,
            name: name,
            artist: artist,
            album: collectionName ?? "Unknown Album",
            artworkURL: artworkUrl100.flatMap { URL(string: $0) },
            genre: primaryGenreName ?? "Unknown Genre",
            releaseYear: parsedYear(from: releaseDate),
            price: trackPrice
        )
    }

    private func parsedYear(from dateString: String?) -> String {
        guard
            let dateString,
            let date = ISO8601DateFormatter().date(from: dateString)
        else { return "Unknown" }
        return String(Calendar.current.component(.year, from: date))
    }
}
