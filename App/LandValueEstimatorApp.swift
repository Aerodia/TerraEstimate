//
//  LandValueEstimatorApp.swift
//  LandValueEstimator
//
//  Step 10: root view is now RootTabView (Estimate + History tabs)
//  instead of EstimatorFormView directly, and .modelContainer(for:)
//  registers SavedEstimate with SwiftData so history persists across
//  app launches.
//

import SwiftUI

@main
struct LandValueEstimatorApp: App {
    var body: some Scene {
        WindowGroup {
            RootTabView()
        }
        .modelContainer(for: SavedEstimate.self)
    }
}
