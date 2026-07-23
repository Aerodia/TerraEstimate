# 🌍 TerraEstimate

> Instant, AI-powered land and property value estimation for iOS.

**TerraEstimate** is a modern, native iOS application built with SwiftUI, SwiftData, and Swift Charts. It provides quick property valuations based on property metrics, visualizes confidence margins, displays model feature importance, and lets users manage their saved valuation history.

---

## ✨ Features

* **⚡ Smart Property Valuations:** Interactive inputs for square footage, bedrooms, bathrooms, property age, location zone, and main road proximity.
* **📊 Feature Importance Breakdown:** Custom horizontal bar charts powered by **Swift Charts** that highlight the key drivers behind each estimate (e.g., square footage, location zone).
* **🎯 Confidence Intervals:** Displays estimated value bounds ($\pm \$24,399$) derived from model validation performance.
* **💾 Estimate History (SwiftData):** Save estimates locally with full persistence. Features single swipe-to-delete and a bulk "Clear All" option with a confirmation modal.
* **✨ Animated Onboarding:** Sleek first-launch onboarding page featuring staggered entrance animations, ambient background glows, and auto-dismissal using `@AppStorage`.
* **🎨 Modern UI/UX:** Built with native iOS card layouts, smooth numerical count-up animations, dark mode support, and interactive haptic feedback.

---

## 🛠️ Tech Stack & Requirements

* **Language:** Swift 5.9+
* **Frameworks:** SwiftUI, SwiftData, Swift Charts
* **Platform:** iOS 17.0+
* **IDE:** Xcode 15.0+

---

## 📂 Project Architecture

```text
LandValueEstimator / TerraEstimate
├── App
│   └── LandValueEstimatorApp.swift      # Main @main entry point & onboarding flow
├── Views
│   ├── LandingView.swift                # Animated welcome / onboarding screen
│   ├── RootTabView.swift                # Main tab navigation bar
│   ├── EstimatorFormView.swift          # Main input form & calculation sheet trigger
│   ├── ResultView.swift                 # Valuation summary modal & save action
│   ├── FeatureImportanceChartView.swift # Swift Charts feature breakdown
│   └── HistoryView.swift                # SwiftData persistent valuation list
├── Models
│   ├── PropertyInput.swift              # Input attributes struct
│   ├── PredictionResult.swift           # Prediction bounds and value formatting
│   ├── SavedEstimate.swift              # SwiftData @Model entity
│   └── FeatureImportance.swift          # Feature importance weights and static data
└── Services / ViewModels
    └── EstimatorViewModel.swift         # Prediction business logic
