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

    private let searchUseCase: SearchTracksUseCaseProtocol
    private var searchTask: Task<Void, Never>?

    init(searchUseCase: SearchTracksUseCaseProtocol) {
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

        isLoading = true
        searchTask = Task {
            defer { isLoading = false }
            do {
                let results = try await searchUseCase.execute(query: searchText)
                guard !Task.isCancelled else { return }
                tracks = results
            } catch {
                guard !Task.isCancelled else { return }
                errorMessage = error.localizedDescription
            }
        }
    }
}
