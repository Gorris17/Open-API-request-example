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

    private let searchService: SearchTracksServiceProtocol
    private var searchTask: Task<Void, Never>?

    init(searchUseCase: SearchTracksServiceProtocol) {
        self.searchService = searchUseCase
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

        searchTask = Task {  // isLoading set after debounce window
            do { try await Task.sleep(for: .milliseconds(300)) }
            catch { return }  // cancelled during debounce window

            isLoading = true
            defer { isLoading = false }
            AppLogger.info("Search started: '\(self.searchText)'", .search)
            do {
                let results = try await searchService.execute(query: searchText)
                guard !Task.isCancelled else {
                    AppLogger.debug("Search cancelled: '\(self.searchText)'", .search)
                    return
                }
                AppLogger.info("Search '\(self.searchText)' → \(results.count) results", .search)
                tracks = results
            } catch {
                guard !Task.isCancelled else {
                    AppLogger.debug("Search cancelled: '\(self.searchText)'", .search)
                    return
                }
                AppLogger.error("Search '\(self.searchText)' failed: \(error)", .search)
                errorMessage = error.localizedDescription
            }
        }
    }
}
