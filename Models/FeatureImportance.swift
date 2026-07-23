//
//  FeatureImportance.swift
//  LandValueEstimator
//
//  Static feature importance data, taken directly from the Random Forest's
//  feature_importances_ output during training.
//
//  *** TODO -- STALE DATA ***
//  The values below are still from the OLD synthetic-data model. After you
//  run load_real_data.py + train_model.py locally (see project notes),
//  copy the new "Random Forest Feature Importance" printout from the
//  console and replace the values below. The feature LIST also changed --
//  distance_to_city_km, near_school, and has_water_access no longer exist
//  in the real-data schema, so those rows should be deleted, not just
//  re-valued.
//
//  Why static and not computed live? Core ML's tree ensemble runtime on
//  iOS doesn't expose per-request feature attribution (that would require
//  something like on-device SHAP, well beyond what's needed here). Instead
//  we show the GLOBAL importances -- "across all the data this model
//  learned from, here's what generally drives price" -- which is honest,
//  useful context without overstating precision for any single estimate.
//
//  Note: the 5 individual location_zone_* importances get combined into a
//  single "Location Zone" entry (sum of all 5) when you update this --
//  showing 5 separate zone bars is confusing to a user; what matters to
//  them is "zone matters a lot," not Zone A's importance specifically.
//
//  Also expect "type_residential"/"type_vacant_land" to show ~0 importance
//  in the new real-data numbers -- that's correct, not a bug. Ames Housing
//  has zero vacant-land sales, so that feature never varies in training
//  data and the model can't learn anything from it. Fine to drop that row
//  entirely rather than show a 0% bar.
//

import Foundation

struct FeatureImportance: Identifiable {
    let id = UUID()
    let label: String
    let value: Double
}

enum FeatureImportanceData {
    /// TODO: replace with real values after retraining -- see file header.
    /// Sorted descending, near-zero entries dropped since they add visual
    /// noise without conveying anything to the user.
    static let all: [FeatureImportance] = [
        FeatureImportance(label: "Size", value: 0.6175),
        FeatureImportance(label: "Location Zone", value: 0.3766),
        FeatureImportance(label: "Bedrooms", value: 0.0006),
        FeatureImportance(label: "Age", value: 0.0005),
        FeatureImportance(label: "Bathrooms", value: 0.0004),
        FeatureImportance(label: "Near Main Road", value: 0.0003),
    ]
}
