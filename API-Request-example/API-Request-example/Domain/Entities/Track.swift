//
//  Track.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

struct Track: Identifiable, Hashable {
    let id: Int
    let name: String
    let artist: String
    let album: String
    let artworkURL: URL?
    let genre: String
    let releaseYear: String
    let price: Double?
}
