//
//  APIService.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case statusCode(Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .invalidURL:            return "Invalid URL."
        case .invalidResponse:       return "Invalid server response."
        case .statusCode(let code):  return "Server returned status code \(code)."
        case .decoding(let error):   return "Decoding error: \(error.localizedDescription)"
        }
    }
}

protocol APIServiceProtocol {
    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T
}

final class APIService: APIServiceProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        let urlRequest = try endpoint.urlRequest()
        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.statusCode(httpResponse.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw APIError.decoding(error)
        }
    }
}
