//
//  HealthTrackApp.swift
//  HealthTrack
//
//  Created by Ajay Sangwan on 24/03/25.
//
import SwiftData
import SwiftUI

@main
struct HealthTrackApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
               
        }
        .modelContainer(for: DataModel.self)
    }
}
