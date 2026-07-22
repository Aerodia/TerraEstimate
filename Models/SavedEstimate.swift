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
    var distanceToCityKm: Double
    var nearMainRoad: Bool
    var nearSchool: Bool
    var hasWaterAccess: Bool

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
        self.distanceToCityKm = input.distanceToCityKm
        self.nearMainRoad = input.nearMainRoad
        self.nearSchool = input.nearSchool
        self.hasWaterAccess = input.hasWaterAccess
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
