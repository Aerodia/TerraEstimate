//
//  EstimatorFormView.swift
//  LandValueEstimator
//
//  Step 6: layout only. All fields are wired to local @State so the form
//  is fully interactive and demonstrable on its own, but the "Get
//  Estimate" button does not call the ML model yet -- that wiring
//  (PredictionService + EstimatorViewModel) happens in Step 7.
//

import SwiftUI

struct EstimatorFormView: View {
    @State private var input = PropertyInput()

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
        }
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
            Text("What are you estimating?")
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
            Text("Size & Location")
        }
    }

    // MARK: - Residential Details (conditional)

    private var residentialDetailsSection: some View {
        Section {
            Stepper(value: $input.bedrooms, in: 0...10) {
                HStack {
                    Text("Bedrooms")
                    Spacer()
                    Text("\(input.bedrooms)")
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $input.bathrooms, in: 0...10) {
                HStack {
                    Text("Bathrooms")
                    Spacer()
                    Text("\(input.bathrooms)")
                        .foregroundStyle(.secondary)
                }
            }

            Stepper(value: $input.ageYears, in: 0...100) {
                HStack {
                    Text("Property Age")
                    Spacer()
                    Text("\(input.ageYears) yrs")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("Property Details")
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
            Text("Location Factors")
        }
    }

    // MARK: - Amenities

    private var amenitiesSection: some View {
        Section {
            Toggle("Near Main Road", isOn: $input.nearMainRoad)
            Toggle("Near School", isOn: $input.nearSchool)
            Toggle("Has Water Access", isOn: $input.hasWaterAccess)
        } header: {
            Text("Amenities")
        }
    }

    // MARK: - Estimate Button

    private var estimateButtonSection: some View {
        Section {
            Button {
                // Step 7 will replace this with a call to
                // EstimatorViewModel.getEstimate(for: input)
                print("Get Estimate tapped with input: \(input)")
            } label: {
                HStack {
                    Spacer()
                    Text("Get Estimate")
                        .fontWeight(.semibold)
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    EstimatorFormView()
}
