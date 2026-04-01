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
        searchUseCase: ServiceFactory.searchTracksUseCase
    )

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
                        VStack(alignment: .leading, spacing: 2) {
                            Text(entity.trackName)
                                .font(.subheadline)
                            Text(entity.artistName)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
    }
}

// MARK: - Row

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
