//
//  PredictionService.swift
//  LandValueEstimator
//
//  Wraps all Core ML interaction. This is the ONE place that needs to
//  know how PropertyInput maps to LandValueModel's 12 named inputs --
//  keeping that mapping in a single spot means if the model is ever
//  retrained/re-exported with a different feature set, this is the only
//  file that needs to change.
//
//  IMPORTANT: Xcode auto-generates a Swift class from LandValueModel.mlmodel
//  (Product Name -> class "LandValueModel"). Because export_coreml.py gave
//  the model 12 individually NAMED inputs (not one combined array), Xcode's
//  generated class exposes a convenience `prediction(...)` method with one
//  keyword argument per feature, matching CORE_ML_INPUT_ORDER from the
//  Python export script:
//
//      size_sqft, bedrooms, bathrooms, age_years, near_main_road,
//      zone_A, zone_B, zone_C, zone_D, zone_E,
//      type_residential, type_vacant_land
//
//  (distance_to_city_km, near_school, has_water_access were REMOVED when
//  the app switched to real Ames Housing data -- see PropertyInput.swift.)
//
//  If Xcode generated a slightly different method signature than what's
//  used below (check by Cmd-clicking `LandValueModel` after adding the
//  .mlmodel to the project), adjust the call in `predict(for:)` to match --
//  the field NAMES and ORDER are what matter, not this exact syntax.
//

import CoreML
import Foundation

enum PredictionError: LocalizedError {
    case modelLoadFailed
    case predictionFailed(Error)

    var errorDescription: String? {
        switch self {
        case .modelLoadFailed:
            return "The valuation model couldn't be loaded."
        case .predictionFailed:
            return "Something went wrong while generating the estimate."
        }
    }
}

final class PredictionService {

    // From metadata.pkl after training: test-set MAE for the winning
    // model. TODO: this value (45,690) is from the OLD synthetic-data
    // model -- update it after retraining on real data (Step: run
    // train_model.py locally and copy the new MAE printed in its output).
    private static let confidenceMargin: Double = 24_399

    private let model: LandValueModel

    init() throws {
        do {
            let configuration = MLModelConfiguration()
            self.model = try LandValueModel(configuration: configuration)
        } catch {
            throw PredictionError.modelLoadFailed
        }
    }

    func predict(for input: PropertyInput) throws -> PredictionResult {
        let zone = oneHotZone(input.locationZone)
        let type = oneHotPropertyType(input.propertyType)

        do {
            let output = try model.prediction(
                size_sqft: input.sizeSqft,
                bedrooms: Double(input.effectiveBedrooms),
                bathrooms: Double(input.effectiveBathrooms),
                age_years: Double(input.effectiveAgeYears),
                near_main_road: input.nearMainRoad ? 1.0 : 0.0,
                zone_A: zone.a,
                zone_B: zone.b,
                zone_C: zone.c,
                zone_D: zone.d,
                zone_E: zone.e,
                type_residential: type.residential,
                type_vacant_land: type.vacantLand
            )

            return PredictionResult(
                estimatedValue: output.price,
                confidenceMargin: Self.confidenceMargin
            )
        } catch {
            throw PredictionError.predictionFailed(error)
        }
    }

    // MARK: - One-hot encoding helpers
    // Mirrors the fixed category order from preprocessing.py exactly.

    private func oneHotZone(_ zone: LocationZone) -> (a: Double, b: Double, c: Double, d: Double, e: Double) {
        (
            a: zone == .zoneA ? 1.0 : 0.0,
            b: zone == .zoneB ? 1.0 : 0.0,
            c: zone == .zoneC ? 1.0 : 0.0,
            d: zone == .zoneD ? 1.0 : 0.0,
            e: zone == .zoneE ? 1.0 : 0.0
        )
    }

    private func oneHotPropertyType(_ type: PropertyType) -> (residential: Double, vacantLand: Double) {
        (
            residential: type == .residential ? 1.0 : 0.0,
            vacantLand: type == .vacantLand ? 1.0 : 0.0
        )
    }
}
