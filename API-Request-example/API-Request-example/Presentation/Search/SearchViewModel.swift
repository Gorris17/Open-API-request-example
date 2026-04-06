//
//  SearchViewModel.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    var searchText: String = ""
    var tracks: [Track] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let searchUseCase: SearchTracksServiceProtocol
    private var searchTask: Task<Void, Never>?

    init(searchUseCase: SearchTracksServiceProtocol) {
        self.searchUseCase = searchUseCase
    }

    /// Cancels any in-flight search and starts a new one for `searchText`.
    func search() {
        searchTask?.cancel()
        tracks = []
        errorMessage = nil

        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            isLoading = false
            return
        }

        AppLogger.search.info("Search started: '\(self.searchText, privacy: .private)'")
        isLoading = true
        searchTask = Task {
            defer { isLoading = false }
            do {
                let results = try await searchUseCase.execute(query: searchText)
                guard !Task.isCancelled else {
                    AppLogger.search.debug("Search cancelled: '\(self.searchText, privacy: .private)'")
                    return
                }
                AppLogger.search.info("Search '\(self.searchText, privacy: .private)' → \(results.count, privacy: .public) results")
                tracks = results
            } catch {
                guard !Task.isCancelled else {
                    AppLogger.search.debug("Search cancelled: '\(self.searchText, privacy: .private)'")
                    return
                }
                AppLogger.search.error("Search '\(self.searchText, privacy: .private)' failed: \(error, privacy: .public)")
                errorMessage = error.localizedDescription
            }
        }
    }
}
