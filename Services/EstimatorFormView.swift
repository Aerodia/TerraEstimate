import SwiftUI
import SwiftData

struct EstimatorFormView: View {
    @StateObject private var viewModel = EstimatorViewModel()
    
    // Form Input States
    @State private var sizeSqft: Double = 1800
    @State private var bedrooms: Int = 3
    @State private var bathrooms: Int = 2
    @State private var ageYears: Int = 15
    @State private var nearMainRoad: Bool = false
    @State private var locationZone: LocationZone = .zoneA
    @State private var propertyType: PropertyType = .residential
    
    // SwiftData context to save estimates
    @Environment(\.modelContext) private var modelContext

    // Corrected parameter order matching PropertyInput struct initialization
    var currentInput: PropertyInput {
        PropertyInput(
            propertyType: propertyType,
            sizeSqft: sizeSqft,
            locationZone: locationZone,
            bedrooms: bedrooms,
            bathrooms: bathrooms,
            ageYears: ageYears,
            nearMainRoad: nearMainRoad
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        
                        // MARK: - Result Hero Card
                        if let result = viewModel.result {
                            resultCard(result: result)
                                .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        // MARK: - Property Dimensions Card
                        inputCard(title: "Property Dimensions", icon: "ruler.fill") {
                            VStack(spacing: 18) {
                                // Square Feet Slider
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Size")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Spacer()
                                        Text("\(Int(sizeSqft)) sq ft")
                                            .font(.subheadline.bold())
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.blue.opacity(0.1))
                                            .clipShape(Capsule())
                                    }
                                    Slider(value: $sizeSqft, in: 500...5000, step: 50)
                                        .tint(.blue)
                                }

                                Divider()

                                // Bedrooms & Bathrooms
                                HStack(spacing: 20) {
                                    Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 1...8)
                                    Stepper("Baths: \(bathrooms)", value: $bathrooms, in: 1...6)
                                }
                                .font(.subheadline)

                                Divider()

                                // Property Age
                                Stepper("Property Age: \(ageYears) yrs", value: $ageYears, in: 0...100)
                                    .font(.subheadline)
                            }
                        }

                        // MARK: - Location & Type Card
                        inputCard(title: "Location & Type", icon: "mappin.and.ellipse") {
                            VStack(spacing: 16) {
                                // Explicit closure typing resolves compiler inference errors
                                Picker("Property Type", selection: $propertyType) {
                                    ForEach(PropertyType.allCases, id: \.self) { (type: PropertyType) in
                                        Text(type.rawValue.capitalized).tag(type)
                                    }
                                }
                                .pickerStyle(.segmented)

                                Picker("Location Zone", selection: $locationZone) {
                                    ForEach(LocationZone.allCases, id: \.self) { (zone: LocationZone) in
                                        Text(zone.rawValue.capitalized).tag(zone)
                                    }
                                }
                                .pickerStyle(.menu)

                                Toggle("Near Main Road", isOn: $nearMainRoad)
                                    .font(.subheadline)
                            }
                        }

                        // MARK: - Primary Action Button
                        Button(action: calculateEstimate) {
                            HStack {
                                if viewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                    Text("Estimate Value")
                                        .bold()
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(LinearGradient(colors: [.blue, .indigo], startPoint: .leading, endPoint: .trailing))
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .disabled(viewModel.isLoading)
                        .sensoryFeedback(.impact, trigger: viewModel.result != nil)

                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Land Estimator")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        withAnimation {
                            viewModel.reset()
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
        }
    }

    // MARK: - Custom Views & Helpers

    @ViewBuilder
    private func inputCard<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
            }
            content()
        }
        .padding(18)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 4)
    }

    @ViewBuilder
    private func resultCard(result: PredictionResult) -> some View {
        VStack(spacing: 16) {
            Text("ESTIMATED MARKET VALUE")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
                .tracking(1.2)

            Text(result.estimatedValue, format: .currency(code: "USD").precision(.fractionLength(0)))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .contentTransition(.numericText())

            // Confidence Range Banner
            HStack(spacing: 6) {
                Image(systemName: "shield.checkmark.fill")
                    .foregroundColor(.green)
                Text("Range: \(result.lowerBound, format: .currency(code: "USD").precision(.fractionLength(0))) – \(result.upperBound, format: .currency(code: "USD").precision(.fractionLength(0)))")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.green.opacity(0.12))
            .clipShape(Capsule())

            Divider()

            // Save Estimate Quick Action
            Button(action: saveCurrentEstimate) {
                Label("Save to History", systemImage: "square.and.arrow.down.fill")
                    .font(.subheadline.bold())
                    .foregroundColor(.blue)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.06), radius: 16, x: 0, y: 6)
        )
    }

    private func calculateEstimate() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            viewModel.getEstimate(for: currentInput)
        }
    }

    private func saveCurrentEstimate() {
        guard let result = viewModel.result else { return }
        let saved = SavedEstimate(input: currentInput, result: result)
        modelContext.insert(saved)
    }
}

#Preview {
    EstimatorFormView()
        .modelContainer(for: SavedEstimate.self, inMemory: true)
}
