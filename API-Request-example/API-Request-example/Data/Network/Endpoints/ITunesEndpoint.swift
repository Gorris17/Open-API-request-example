//
//  ITunesEndpoint.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import Foundation

enum ITunesEndpoint: Endpoint {
    case search(query: String, limit: Int = 25)

    var baseURL: URL {
        // swiftlint:disable:next force_unwrapping
        URL(string: "https://itunes.apple.com")!
    }

    var path: String {
        switch self {
        case .search: return "/search"
        }
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .search(let query, let limit):
            return [
                URLQueryItem(name: "term",   value: query),
                URLQueryItem(name: "entity", value: "song"),
                URLQueryItem(name: "limit",  value: String(limit))
            ]
        }
    }

    var method: HTTPMethod { .GET }
}
