//
//  TrackRepositoryProtocol.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

protocol TrackRepositoryProtocol {
    func search(query: String) async throws -> [Track]
}
