//
//  QuoteVaultApp.swift
//  QuoteVault
//
//  Created by Deepanshu Maliyaan on 21/01/26.
//

import SwiftUI
import SwiftData

@main
struct QuoteVaultApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CachedQuote.self,
            CachedCollection.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(sharedModelContainer)
    }
}
