//
//  DetailView.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import SwiftUI
import SwiftData

struct DetailView: View {
    let track: Track
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                artworkView

                VStack(spacing: 0) {
                    DetailRow(label: "Song",   value: track.name)
                    DetailRow(label: "Artist", value: track.artist)
                    DetailRow(label: "Album",  value: track.album)
                    DetailRow(label: "Genre",  value: track.genre)
                    DetailRow(label: "Year",   value: track.releaseYear)
                    if let price = track.price {
                        DetailRow(label: "Price", value: String(format: "$%.2f", price))
                    }
                }
                .background(Color(.systemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle(track.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { saveRecentTrack() }
    }

    // MARK: - Artwork

    private var artworkView: some View {
        AsyncImage(url: largeArtworkURL) { image in
            image.resizable().aspectRatio(contentMode: .fit)
        } placeholder: {
            Color.secondary.opacity(0.2)
        }
        .frame(width: 220, height: 220)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 8)
    }

    private var largeArtworkURL: URL? {
        guard let url = track.artworkURL else { return nil }
        let larger = url.absoluteString.replacingOccurrences(of: "100x100", with: "300x300")
        return URL(string: larger) ?? url
    }

    // MARK: - Persistence

    private func saveRecentTrack() {
        let id = track.id
        let descriptor = FetchDescriptor<RecentTrackEntity>(
            predicate: #Predicate { $0.trackId == id }
        )
        if let existing = try? modelContext.fetch(descriptor).first {
            existing.viewedAt = Date()
            AppLogger.persistence.debug("Updated viewedAt for track \(id, privacy: .public)")
        } else {
            modelContext.insert(RecentTrackEntity(track: track))
            AppLogger.persistence.info("Persisted new track \(id, privacy: .public) '\(self.track.name, privacy: .private)'")
        }
    }
}

// MARK: - Detail row

private struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .frame(width: 56, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        Divider().padding(.leading, 84)
    }
}

#Preview {
    NavigationStack {
        DetailView(track: Track(
            id: 1,
            name: "Bohemian Rhapsody",
            artist: "Queen",
            album: "A Night at the Opera",
            artworkURL: nil,
            genre: "Rock",
            releaseYear: "1975",
            price: 1.29
        ))
    }
    .modelContainer(for: RecentTrackEntity.self, inMemory: true)
}
