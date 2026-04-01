//
//  TrackRepository.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

protocol TrackRepository {
    func search(query: String) async throws -> [Track]
}
