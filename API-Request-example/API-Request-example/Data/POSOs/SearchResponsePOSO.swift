//
//  SearchResponsePOSO.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

struct SearchResponsePOSO: Decodable {
    let resultCount: Int
    let results: [TrackPOSO]
}
