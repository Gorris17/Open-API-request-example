//
//  API_Request_exampleApp.swift
//  API-Request-example
//
//  Created by Fernando Corral on 1/4/26.
//

import SwiftUI
import SwiftData

@main
struct API_Request_exampleApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([RecentTrackEntity.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            SearchView()
        }
        .modelContainer(sharedModelContainer)
    }
}
