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
import SwiftData

@main
struct LandValueEstimatorApp: App {
    @AppStorage("hasSeenLanding") private var hasSeenLanding: Bool = false

    var body: some Scene {
        WindowGroup {
            if hasSeenLanding {
                RootTabView()
                    .modelContainer(for: SavedEstimate.self)
            } else {
                LandingView {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        hasSeenLanding = true
                    }
                }
            }
        }
    }
}
