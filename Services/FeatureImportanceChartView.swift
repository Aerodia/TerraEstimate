//
//  FeatureImportanceChartView.swift
//  LandValueEstimator
//

import Charts
import SwiftUI

struct FeatureImportanceChartView: View {
    let data: [FeatureImportance]

    private var topFeatures: [FeatureImportance] {
        Array(data.sorted { $0.value > $1.value }.prefix(6))
    }

    var body: some View {
        if topFeatures.isEmpty {
            // Placeholder if no data is provided
            Text("No feature importance data available")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(height: 120)
                .frame(maxWidth: .infinity)
        } else {
            Chart(topFeatures) { feature in
                BarMark(
                    x: .value("Importance", feature.value),
                    y: .value("Feature", feature.label)
                )
                .foregroundStyle(Color.accentColor.gradient)
                .annotation(position: .trailing) {
                    Text(feature.value, format: .percent.precision(.fractionLength(0...1)))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .chartXAxis(.hidden)
            .chartXScale(domain: 0...(topFeatures.first?.value ?? 1) * 1.25)
            // Ensure minimum frame height (at least 180) so it never collapses in a ScrollView
            .frame(height: max(180, CGFloat(topFeatures.count) * 36 + 12))
        }
    }
}

#Preview {
    FeatureImportanceChartView(data: FeatureImportanceData.all)
        .padding()
}
