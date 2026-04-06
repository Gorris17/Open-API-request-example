//
//  SearchView.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel = SearchViewModel(
        searchUseCase: ServiceFactory.searchTracksService
    )

    @Environment(\.modelContext) private var modelContext

    // Recently viewed tracks stored via SwiftData.
    @Query(sort: \RecentTrackEntity.viewedAt, order: .reverse)
    private var recentTracks: [RecentTrackEntity]

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.searchText.isEmpty {
                    recentSection
                } else {
                    resultsList
                }
            }
            .navigationTitle("iTunes Search")
            .searchable(text: $viewModel.searchText, prompt: "Search songs…")
            .onChange(of: viewModel.searchText) { viewModel.search() }
            .navigationDestination(for: Track.self) { track in
                DetailView(track: track)
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var resultsList: some View {
        List(viewModel.tracks) { track in
            NavigationLink(value: track) {
                TrackRowView(track: track)
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            } else if let error = viewModel.errorMessage {
                ContentUnavailableView(
                    "Something went wrong",
                    systemImage: "exclamationmark.triangle",
                    description: Text(error)
                )
            } else if viewModel.tracks.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var recentSection: some View {
        if recentTracks.isEmpty {
            ContentUnavailableView(
                "Search for music",
                systemImage: "magnifyingglass",
                description: Text("Type a song, artist or album name.")
            )
        } else {
            List {
                Section("Recently Viewed") {
                    ForEach(recentTracks) { entity in
                        NavigationLink(value: entity.toDomain()) {
                            RecentTrackRowView(entity: entity)
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { modelContext.delete(recentTracks[$0]) }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Recent track row

private struct RecentTrackRowView: View {
    let entity: RecentTrackEntity

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entity.trackName)
                    .font(.subheadline)
                Text(entity.artistName)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            TimelineView(.periodic(from: .now, by: 60)) { context in
                Text(relativeTime(from: entity.viewedAt, to: context.date))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .monospacedDigit()
            }
        }
    }

    private func relativeTime(from date: Date, to now: Date) -> String {
        let seconds = Int(now.timeIntervalSince(date))
        guard seconds >= 0 else { return "Just now" }
        if seconds < 60   { return "Just now" }
        let minutes = seconds / 60
        if minutes < 60   { return "\(minutes) min ago" }
        let hours = minutes / 60
        if hours < 24     { return "\(hours)h ago" }
        return "\(hours / 24)d ago"
    }
}

// MARK: - Search result row

private struct TrackRowView: View {
    let track: Track

    var body: some View {
        HStack(spacing: 12) {
            AsyncImage(url: track.artworkURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.secondary.opacity(0.2)
            }
            .frame(width: 50, height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                Text(track.name)
                    .font(.headline)
                    .lineLimit(1)
                Text(track.artist)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(track.album)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    SearchView()
        .modelContainer(for: RecentTrackEntity.self, inMemory: true)
}
