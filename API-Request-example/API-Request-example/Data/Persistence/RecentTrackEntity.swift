//
//  RecentTrackEntity.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import SwiftData

/// SwiftData persistent model storing recently viewed tracks.
@Model
final class RecentTrackEntity {
    var trackId: Int
    var trackName: String
    var artistName: String
    var viewedAt: Date

    init(trackId: Int, trackName: String, artistName: String) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.viewedAt = Date()
    }
}
