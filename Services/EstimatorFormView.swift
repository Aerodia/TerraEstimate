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
    
    // Sheet Trigger State
    @State private var showResultSheet: Bool = false
    
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
                        
                        // MARK: - Property Dimensions Card
                        inputCard(title: "Property Dimensions", icon: "ruler.fill") {
                            VStack(spacing: 18) {
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

                                HStack(spacing: 20) {
                                    Stepper("Bedrooms: \(bedrooms)", value: $bedrooms, in: 1...8)
                                    Stepper("Baths: \(bathrooms)", value: $bathrooms, in: 1...6)
                                }
                                .font(.subheadline)

                                Divider()

                                Stepper("Property Age: \(ageYears) yrs", value: $ageYears, in: 0...100)
                                    .font(.subheadline)
                            }
                        }

                        // MARK: - Location & Type Card
                        inputCard(title: "Location & Type", icon: "mappin.and.ellipse") {
                            VStack(spacing: 16) {
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
            .navigationTitle("") // Hide standard title string
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("TerraEstimate")
                        .font(.title2.bold())
                        .foregroundColor(.primary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        withAnimation {
                            viewModel.reset()
                        }
                    }
                    .foregroundColor(.secondary)
                }
            }
            // MARK: - Sheet Presentation for ResultView
            .sheet(isPresented: $showResultSheet) {
                if let result = viewModel.result {
                    ResultView(
                        input: currentInput,
                        result: result,
                        onDismiss: { showResultSheet = false }
                    )
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

    private func calculateEstimate() {
        viewModel.getEstimate(for: currentInput)
        // Present sheet once computation finishes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if viewModel.result != nil {
                showResultSheet = true
            }
        }
    }
}

#Preview {
    EstimatorFormView()
        .modelContainer(for: SavedEstimate.self, inMemory: true)
}
