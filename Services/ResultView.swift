//
//  ResultView.swift
//  LandValueEstimator
//
//  Presented as a sheet from EstimatorFormView once a prediction succeeds.
//  Replaces the temporary inline result card used in Step 7.
//

import SwiftData
import SwiftUI
import UIKit

struct ResultView: View {
    let input: PropertyInput
    let result: PredictionResult
    var onDismiss: () -> Void

    @Environment(\.modelContext) private var modelContext

    /// Drives the count-up animation on appear -- starts at 0 and animates
    /// to the real estimate so the number doesn't just pop into place.
    @State private var displayedValue: Double = 0
    @State private var isSaved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    estimateHeader
                    rangeCard
                    featureImportanceCard
                    saveButton
                }
                .padding()
            }
            .navigationTitle("Your Estimate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: onDismiss)
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 1.0)) {
                    displayedValue = result.estimatedValue
                }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
            }
        }
    }

    // MARK: - Header

    private var estimateHeader: some View {
        VStack(spacing: 6) {
            Text("Estimated Value")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(displayedValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 44, weight: .bold, design: .rounded))
                .contentTransition(.numericText(value: displayedValue))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
    }

    // MARK: - Confidence Range

    private var rangeCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("Confidence Range", systemImage: "arrow.left.and.right")
                .font(.subheadline.weight(.semibold))

            HStack {
                Text(result.formattedLowerBound)
                Spacer()
                Text(result.formattedUpperBound)
            }
            .font(.callout)
            .foregroundStyle(.secondary)

            Capsule()
                .fill(Color.accentColor.opacity(0.2))
                .frame(height: 6)
                .overlay(alignment: .center) {
                    Capsule()
                        .fill(Color.accentColor)
                        .frame(width: 24, height: 6)
                }

            Text("Based on this model's typical prediction error (± \(result.formattedConfidenceMargin)) on held-out test data.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Feature Importance

    private var featureImportanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("What Drives This Estimate", systemImage: "chart.bar.fill")
                .font(.subheadline.weight(.semibold))

            Text("Based on the model's training data, in general:")
                .font(.caption)
                .foregroundStyle(.secondary)

            FeatureImportanceChartView(data: FeatureImportanceData.all)
        }
        .padding()
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Save to History

    private var saveButton: some View {
        Button {
            let record = SavedEstimate(input: input, result: result)
            modelContext.insert(record)
            isSaved = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
        } label: {
            HStack {
                Spacer()
                Label(
                    isSaved ? "Saved to History" : "Save to History",
                    systemImage: isSaved ? "checkmark.circle.fill" : "square.and.arrow.down"
                )
                .fontWeight(.semibold)
                Spacer()
            }
        }
        .buttonStyle(.borderedProminent)
        .disabled(isSaved)
    }
}

#Preview {
    ResultView(
        input: PropertyInput(),
        result: PredictionResult(estimatedValue: 412_500, confidenceMargin: 45_690),
        onDismiss: {}
    )
    .modelContainer(for: SavedEstimate.self, inMemory: true)
}
