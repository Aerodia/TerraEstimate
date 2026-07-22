//
//  PropertyInput.swift
//  LandValueEstimator
//
//  Represents everything collected from the estimator form. The property
//  names and the two enums below are deliberately aligned with the 15
//  Core ML input features baked into LandValueModel.mlmodel (see
//  export_coreml.py -> CORE_ML_INPUT_ORDER on the Python side) so that
//  PredictionService (Step 7) can map this struct to the model inputs
//  with no ambiguity.
//

import Foundation

enum LocationZone: String, CaseIterable, Identifiable {
    case zoneA = "Zone A"
    case zoneB = "Zone B"
    case zoneC = "Zone C"
    case zoneD = "Zone D"
    case zoneE = "Zone E"

    var id: String { rawValue }

    /// Short subtitle shown under the zone name in the picker, to help
    /// users who don't know the app's zone convention pick intuitively.
    var subtitle: String {
        switch self {
        case .zoneA: return "Premium / urban core"
        case .zoneB: return "Urban"
        case .zoneC: return "Suburban"
        case .zoneD: return "Outer suburbs"
        case .zoneE: return "Rural / outskirts"
        }
    }
}

enum PropertyType: String, CaseIterable, Identifiable {
    case residential = "Residential"
    case vacantLand = "Vacant Land"

    var id: String { rawValue }
}

struct PropertyInput {
    // NOTE ON RANGES: the UI (EstimatorFormView) constrains sliders/steppers
    // to roughly match what the training data actually contained (see
    // data_generator.py). Predictions for inputs far outside that range
    // are extrapolation -- the model has never seen anything like them --
    // so keeping the UI bounds aligned with training data avoids silently
    // unreliable estimates.
    var propertyType: PropertyType = .residential
    var sizeSqft: Double = 1800
    var locationZone: LocationZone = .zoneC

    // Residential-only fields (ignored / sent as 0 for vacant land)
    var bedrooms: Int = 3
    var bathrooms: Int = 2
    var ageYears: Int = 10

    var distanceToCityKm: Double = 8

    var nearMainRoad: Bool = false
    var nearSchool: Bool = false
    var hasWaterAccess: Bool = false

    /// Effective values enforce the same rule the training data used:
    /// vacant land always has 0 bedrooms/bathrooms/age, regardless of
    /// what's left over in the form state from a previous toggle.
    var effectiveBedrooms: Int { propertyType == .vacantLand ? 0 : bedrooms }
    var effectiveBathrooms: Int { propertyType == .vacantLand ? 0 : bathrooms }
    var effectiveAgeYears: Int { propertyType == .vacantLand ? 0 : ageYears }
}
