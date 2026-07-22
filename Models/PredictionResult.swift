//
//  PredictionResult.swift
//  LandValueEstimator
//

import Foundation

struct PredictionResult {
    let estimatedValue: Double
    let confidenceMargin: Double

    var lowerBound: Double { max(0, estimatedValue - confidenceMargin) }
    var upperBound: Double { estimatedValue + confidenceMargin }

    private static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter
    }()

    var formattedEstimate: String {
        Self.currencyFormatter.string(from: NSNumber(value: estimatedValue)) ?? "$--"
    }

    var formattedLowerBound: String {
        Self.currencyFormatter.string(from: NSNumber(value: lowerBound)) ?? "$--"
    }

    var formattedUpperBound: String {
        Self.currencyFormatter.string(from: NSNumber(value: upperBound)) ?? "$--"
    }
}
