//
//  FeatureImportanceChartView.swift
//  LandValueEstimator
//
//  Horizontal bar chart (Swift Charts, iOS 17+) showing which inputs
//  generally drive the model's price predictions. See FeatureImportance.swift
//  for why this is global/static rather than per-prediction.
//

import Charts
import SwiftUI

struct FeatureImportanceChartView: View {
    let data: [FeatureImportance]

    /// Only the top few, so the chart stays readable -- the long tail of
    /// near-zero features doesn't add insight, just clutter.
    private var topFeatures: [FeatureImportance] {
        Array(data.sorted { $0.value > $1.value }.prefix(6))
    }

    var body: some View {
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
        .frame(height: CGFloat(topFeatures.count) * 36 + 8)
    }
}

#Preview {
    FeatureImportanceChartView(data: FeatureImportanceData.all)
        .padding()
}
