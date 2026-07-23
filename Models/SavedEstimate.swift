//
//  SavedEstimate.swift
//  LandValueEstimator
//
//  SwiftData model persisting a past estimate to disk, so the History tab
//  survives app relaunches. Stores both the inputs that produced the
//  estimate and the result itself -- a bare price number with no context
//  isn't useful to look back on.
//
//  Enums are stored as raw String values (SwiftData's @Model doesn't
//  persist Swift enums directly in a way that's safe across schema
//  changes), with computed properties to convert back to the real enum.
//
//  SCHEMA CHANGE NOTE: distanceToCityKm, nearSchool, and hasWaterAccess
//  were removed when the app switched to real Ames Housing data (no
//  real-data equivalent -- see PropertyInput.swift). SwiftData's
//  lightweight migration usually handles a dropped property fine, but
//  since this project has no explicit versioned schema set up, the
//  safest move is to delete the app from the simulator/device before
//  installing this version, rather than risk a migration edge case with
//  old saved history entries.
//

import Foundation
import SwiftData

@Model
final class SavedEstimate {
    var date: Date
    var estimatedValue: Double
    var confidenceMargin: Double

    var propertyTypeRaw: String
    var sizeSqft: Double
    var locationZoneRaw: String
    var bedrooms: Int
    var bathrooms: Int
    var ageYears: Int
    var nearMainRoad: Bool

    init(input: PropertyInput, result: PredictionResult, date: Date = .now) {
        self.date = date
        self.estimatedValue = result.estimatedValue
        self.confidenceMargin = result.confidenceMargin

        self.propertyTypeRaw = input.propertyType.rawValue
        self.sizeSqft = input.sizeSqft
        self.locationZoneRaw = input.locationZone.rawValue
        self.bedrooms = input.effectiveBedrooms
        self.bathrooms = input.effectiveBathrooms
        self.ageYears = input.effectiveAgeYears
        self.nearMainRoad = input.nearMainRoad
    }

    var propertyType: PropertyType {
        PropertyType(rawValue: propertyTypeRaw) ?? .residential
    }

    var locationZone: LocationZone {
        LocationZone(rawValue: locationZoneRaw) ?? .zoneC
    }

    var result: PredictionResult {
        PredictionResult(estimatedValue: estimatedValue, confidenceMargin: confidenceMargin)
    }

    /// Short summary line shown under the price in the history list,
    /// e.g. "1,800 sq ft · Zone C · Residential"
    var summaryLine: String {
        "\(Int(sizeSqft)) sq ft · \(locationZoneRaw) · \(propertyTypeRaw)"
    }
}
