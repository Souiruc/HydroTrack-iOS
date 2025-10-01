//
//  HydroTrackApp.swift
//  HydroTrack
//
//  Created by Batuhan Aydin on 9/24/25.
//

import SwiftUI

@main
struct HydroTrackApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
