//
//  EstimatorFormView.swift
//  LandValueEstimator
//
//  Form fields are local @State (Step 6). "Get Estimate" calls into
//  EstimatorViewModel -> PredictionService -> Core ML (Step 7), and the
//  result is now presented as a dedicated ResultView sheet (Step 8).
//

import SwiftUI

struct EstimatorFormView: View {
    @State private var input = PropertyInput()
    @StateObject private var viewModel = EstimatorViewModel()

    var body: some View {
        NavigationStack {
            Form {
                propertyTypeSection
                sizeAndLocationSection

                if input.propertyType == .residential {
                    residentialDetailsSection
                }

                locationFactorsSection
                amenitiesSection
                estimateButtonSection
            }
            .navigationTitle("Land Value Estimator")
            .alert(
                "Estimate Failed",
                isPresented: .constant(viewModel.errorMessage != nil),
                actions: {
                    Button("OK") { viewModel.reset() }
                },
                message: {
                    Text(viewModel.errorMessage ?? "Unknown error")
                }
            )
            .sheet(isPresented: resultSheetBinding) {
                if let result = viewModel.result, let submittedInput = viewModel.lastInput {
                    ResultView(input: submittedInput, result: result, onDismiss: { viewModel.reset() })
                }
            }
        }
    }

    /// Bridges viewModel.result (an Optional) to the Bool that .sheet expects.
    /// Dismissing the sheet (either via the Done button or a swipe) calls
    /// viewModel.reset() so a stale result doesn't linger for the next estimate.
    private var resultSheetBinding: Binding<Bool> {
        Binding(
            get: { viewModel.result != nil },
            set: { isPresented in
                if !isPresented { viewModel.reset() }
            }
        )
    }

    // MARK: - Property Type

    private var propertyTypeSection: some View {
        Section {
            Picker("Property Type", selection: $input.propertyType) {
                ForEach(PropertyType.allCases) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Label("What are you estimating?", systemImage: "questionmark.circle.fill")
        }
    }

    // MARK: - Size & Location

    private var sizeAndLocationSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Size")
                    Spacer()
                    Text("\(Int(input.sizeSqft)) sq ft")
                        .foregroundStyle(.secondary)
                }
                Slider(value: $input.sizeSqft, in: 300...15000, step: 50)
            }

            Picker("Location Zone", selection: $input.locationZone) {
                ForEach(LocationZone.allCases) { zone in
                    VStack(alignment: .leading) {
                        Text(zone.rawValue)
                        Text(zone.subtitle)
                    }
                    .tag(zone)
                }
            }
        } header: {
            Label("Size & Location", systemImage: "ruler.fill")
        }
    }

    // MARK: - Residential Details (conditional)

    private var residentialDetailsSection: some View {
        Section {
            Stepper(value: $input.bedrooms, in: 0...5) {
                HStack {
                    Text("Bedrooms")
                    Spacer()
                    Text("\(input.bedrooms)")
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $input.bathrooms, in: 0...5) {
                HStack {
                    Text("Bathrooms")
                    Spacer()
                    Text("\(input.bathrooms)")
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $input.ageYears, in: 0...59) {
                HStack {
                    Text("Property Age")
                    Spacer()
                    Text("\(input.ageYears) yrs")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Label("Property Details", systemImage: "house.fill")
        } footer: {
            Text("Ranges reflect what the estimator was trained on, for the most reliable results.")
        }
    }

    // MARK: - Location Factors

    private var locationFactorsSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Distance to City Center")
                    Spacer()
                    Text(String(format: "%.1f km", input.distanceToCityKm))
                        .foregroundStyle(.secondary)
                }
                Slider(value: $input.distanceToCityKm, in: 0...60, step: 0.5)
            }
        } header: {
            Label("Location Factors", systemImage: "location.fill")
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        Section {
            Toggle("Near Main Road", isOn: $input.nearMainRoad)
            Toggle("Near School", isOn: $input.nearSchool)
            Toggle("Has Water Access", isOn: $input.hasWaterAccess)
        } header: {
            Label("Amenities", systemImage: "star.fill")
        }
    }

    // MARK: - Estimate Button

    private var estimateButtonSection: some View {
        Section {
            Button {
                viewModel.getEstimate(for: input)
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Get Estimate", systemImage: "sparkles")
                            .fontWeight(.semibold)
                    }
                    Spacer()
                }
            }
            .disabled(viewModel.isLoading)
            .listRowBackground(Color.accentColor)
            .foregroundStyle(.white)
        }
    }
}

#Preview {
    EstimatorFormView()
}
