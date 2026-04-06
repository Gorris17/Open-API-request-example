//
//  APIService.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation
import OSLog

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
        AppLogger.network.debug("→ \(urlRequest.httpMethod ?? "GET", privacy: .public) \(urlRequest.url?.absoluteString ?? "", privacy: .public)")

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.network.error("Invalid response (not HTTPURLResponse)")
            throw APIError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            AppLogger.network.error("HTTP \(httpResponse.statusCode, privacy: .public) from \(urlRequest.url?.absoluteString ?? "", privacy: .public)")
            throw APIError.statusCode(httpResponse.statusCode)
        }

        AppLogger.network.debug("← \(httpResponse.statusCode, privacy: .public) (\(data.count, privacy: .public) bytes)")

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            AppLogger.network.error("Decoding failed: \(error, privacy: .public)")
            throw APIError.decoding(error)
        }
    }
}
