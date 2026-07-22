//
//  FeatureImportance.swift
//  LandValueEstimator
//
//  Static feature importance data, taken directly from the Random Forest's
//  feature_importances_ output during training (Step 3's console output).
//
//  Why static and not computed live? Core ML's tree ensemble runtime on
//  iOS doesn't expose per-request feature attribution (that would require
//  something like on-device SHAP, well beyond what's needed here). Instead
//  we show the GLOBAL importances -- "across all the data this model
//  learned from, here's what generally drives price" -- which is honest,
//  useful context without overstating precision for any single estimate.
//
//  If the model is ever retrained on new/different data, update these
//  values from the new "Random Forest Feature Importance" printout in
//  train_model.py's output.
//
//  Note: the 5 individual location_zone_* importances from training were
//  combined into a single "Location Zone" entry here (0.2084 + 0.0920 +
//  0.0494 + 0.0166 + 0.0102 = 0.3766) since showing 5 separate zone bars
//  is confusing to a user -- what matters to them is "zone matters a lot",
//  not the relative importance of Zone A specifically.
//

import Foundation

struct FeatureImportance: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

enum FeatureImportanceData {
    /// Sorted descending, near-zero entries (property type) dropped since
    /// they add visual noise without conveying anything to the user.
    static let all: [FeatureImportance] = [
        FeatureImportance(label: "Size", value: 0.6175),
        FeatureImportance(label: "Location Zone", value: 0.3766),
        FeatureImportance(label: "Distance to City", value: 0.0031),
        FeatureImportance(label: "Bedrooms", value: 0.0006),
        FeatureImportance(label: "Age", value: 0.0005),
        FeatureImportance(label: "Near School", value: 0.0005),
        FeatureImportance(label: "Water Access", value: 0.0004),
        FeatureImportance(label: "Bathrooms", value: 0.0004),
        FeatureImportance(label: "Near Main Road", value: 0.0003),
    ]
}
