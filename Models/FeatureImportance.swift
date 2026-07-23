import Foundation

struct FeatureImportance: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

struct FeatureImportanceData {
    static let all: [FeatureImportance] = [
        FeatureImportance(label: "Total Sq Ft", value: 0.42),
        FeatureImportance(label: "Location Zone", value: 0.28),
        FeatureImportance(label: "Property Age", value: 0.16),
        FeatureImportance(label: "Bathrooms", value: 0.08),
        FeatureImportance(label: "Bedrooms", value: 0.04),
        FeatureImportance(label: "Near Main Road", value: 0.02)
    ]
}
