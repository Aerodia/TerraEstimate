//
//  EstimatorViewModel.swift
//  LandValueEstimator
//
//  Holds form-adjacent state that the View shouldn't manage directly:
//  the prediction result, loading state, and any error to surface.
//  EstimatorFormView owns the PropertyInput itself and passes it in;
//  this keeps PropertyInput easy to preview/test without a ViewModel.
//

import Combine
import Foundation

@MainActor
final class EstimatorViewModel: ObservableObject {
    @Published private(set) var result: PredictionResult?
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false
    @Published private(set) var lastInput: PropertyInput?

    private var predictionService: PredictionService?
    private var modelLoadError: String?

    init() {
        do {
            predictionService = try PredictionService()
        } catch {
            // Surfaced the first time the user actually tries to get an
            // estimate, rather than immediately on app launch -- no need
            // to interrupt someone who's just browsing the form.
            modelLoadError = "The valuation model couldn't be loaded. Try reinstalling the app."
        }
    }

    func getEstimate(for input: PropertyInput) {
        guard let predictionService else {
            errorMessage = modelLoadError ?? "The valuation model is unavailable."
            return
        }

        isLoading = true
        errorMessage = nil
        lastInput = input

        // Core ML inference on a Random Forest this small is effectively
        // instant, but we still hop off the main thread so the UI never
        // has a chance to hitch, and to keep this ready for a future
        // remote-model swap (Option B from Phase 1) without changing the View.
        Task {
            do {
                let prediction = try predictionService.predict(for: input)
                self.result = prediction
            } catch {
                self.errorMessage = error.localizedDescription
                self.result = nil
            }
            self.isLoading = false
        }
    }

    func reset() {
        result = nil
        errorMessage = nil
        lastInput = nil
    }
}
