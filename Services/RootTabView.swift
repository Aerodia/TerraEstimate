//
//  RootTabView.swift
//  LandValueEstimator
//
//  Root of the app now that there are two destinations. This replaces
//  EstimatorFormView as the WindowGroup's content in
//  LandValueEstimatorApp.swift -- see Step 10 install instructions.
//

import SwiftUI
import SwiftData

struct RootTabView: View {
    var body: some View {
        TabView {
            EstimatorFormView()
                .tabItem {
                    Label("Estimate", systemImage: "sparkles")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
        }
    }
}

#Preview {
    RootTabView()
        .modelContainer(for: SavedEstimate.self, inMemory: true)
}
