# TerraEstimate

**An iOS app that estimates real-world property values entirely on-device, using a Random Forest model trained on real housing transaction data and deployed via Core ML.**

No backend. No API calls. No network required at runtime — the trained model ships inside the app and every prediction runs locally on the device.

![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)
![Swift](https://img.shields.io/badge/Swift-SwiftUI-orange)
![ML](https://img.shields.io/badge/ML-Core%20ML%20%2F%20scikit--learn-yellow)

---

## Table of Contents

- [What It Does](#what-it-does)
- [Screenshots](#screenshots)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Machine Learning Pipeline](#machine-learning-pipeline)
- [Model Performance](#model-performance)
- [How Predictions Are Explained](#how-predictions-are-explained)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Known Limitations](#known-limitations)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [Acknowledgments](#acknowledgments)
- [License](#license)

---

## What It Does

TerraEstimate takes a handful of property details — size, bedrooms, bathrooms, age, location zone, and road proximity — and returns an instant, on-device estimated value, along with:

- A **confidence range** based on the model's real test-set error margin
- A **feature importance breakdown** showing what actually drives the estimate
- A **saved history** of past estimates, persisted locally with SwiftData

## Screenshots

<img width="475" height="952" alt="Main Screen" src="https://github.com/user-attachments/assets/98dd1cdc-249f-4a97-838a-390f10067285" />
<img width="475" height="952" alt="Estimation" src="https://github.com/user-attachments/assets/40bf4c46-2766-4eb8-bd5d-df28053f3883" />
<img width="475" height="952" alt="History " src="https://github.com/user-attachments/assets/06e00ecb-b363-42e9-be77-2a303f63fe2e" />


## Architecture

<img width="794" height="350" alt="Screenshot 2026-07-29 at 17 01 53" src="https://github.com/user-attachments/assets/a34e0804-c133-4e2f-9a4f-37f6f54c4ab6" />

The app is split into two independent pieces that only communicate through a single artifact — the exported `.mlmodel` file:

1. **`MLTraining/`** — a Python pipeline (data → preprocessing → training → Core ML export) that produces the model. This runs entirely offline from the app and only needs to be re-run when the model itself changes.
2. **`LandValueEstimator/`** — the iOS app, which treats the bundled model as a black box: input in, prediction out. No knowledge of how the model was trained lives in the Swift code beyond the exact feature order it expects.

This separation means the model can be retrained on new data, a different region, or a different algorithm entirely without touching the iOS app's UI code — only `PredictionService.swift`'s input-encoding logic needs to stay in sync with whatever schema the current model expects.

## Tech Stack

| Layer | Technology |
|---|---|
| iOS App | Swift, SwiftUI (iOS 17+) |
| On-device ML | Core ML |
| Model Training | Python, scikit-learn, pandas |
| Model Export | coremltools |
| Persistence | SwiftData |
| Charts | Swift Charts |

## Machine Learning Pipeline

The model went through two phases:

1. **Prototype phase** — trained on a synthetic, generated dataset to validate the full pipeline (data → training → Core ML export → on-device inference) end to end before touching real data. This let architecture bugs get caught early, without the added variable of real-world data quality issues.
2. **Production phase** — retrained on the **Ames Housing dataset** (De Cock, 2011): 1,450+ real residential property sales from Ames, Iowa (2006–2010), fetched via `scikit-learn`'s OpenML integration.

Switching from synthetic to real data surfaced a genuinely useful signal: the model's R² dropped from a suspiciously perfect 0.97 on synthetic data to a more honest 0.76 on real transactions. That drop is expected and healthy — real-world prices carry noise (renovation quality, staging, negotiation, timing) that a hand-built synthetic dataset simply doesn't have. A model that claims near-perfect accuracy on real housing data would be more likely to indicate a data leak than genuine skill.

**Feature engineering notes:**
- `location_zone` is derived from the dataset's 28 neighborhoods, bucketed into 5 price-quintile zones (Zone A = priciest 20% of neighborhoods, Zone E = cheapest 20%)
- `near_main_road` is derived from the dataset's `Condition1` field (adjacent to an arterial or feeder street)
- Three fields present in an earlier prototype version (`distance_to_city_km`, `near_school`, `has_water_access`) were **deliberately removed** once real data was introduced — the real dataset had no equivalent for them, and a form field with zero real effect on the prediction is misleading rather than merely imprecise

## Model Performance

Two models were trained and compared on held-out test data; **Random Forest** was selected as the production model:

| Model | R² | MAE |
|---|---|---|
| Linear Regression (baseline) | ~0.71 | ~$26.9K |
| **Random Forest (production)** | **0.76** | **$24,399** |

`$24,399` is surfaced directly in the app as the estimate's confidence range (± that amount), rather than presenting a single number with false precision.

## How Predictions Are Explained

Core ML's tree-ensemble runtime doesn't expose per-request feature attribution on-device (that would require something closer to on-device SHAP, well beyond this project's scope). Rather than fake a more precise explanation than the model can actually give, the app shows **global feature importance** — what generally drives price across all the training data — as honest, useful context rather than an overstated per-prediction breakdown.

Top drivers, by learned importance:

| Feature | Importance |
|---|---|
| Size | 51.9% |
| Location Zone | 26.3% |
| Age | 17.6% |
| Bedrooms | 3.5% |
| Bathrooms | 0.7% |
| Near Main Road | 0.1% |

## Project Structure

```
TerraEstimate/
├── LandValueEstimator/              # iOS app (Xcode project)
│   ├── App/                          # App entry point, SwiftData container setup
│   ├── Models/                       # PropertyInput, PredictionResult, SavedEstimate, FeatureImportance
│   ├── ViewModels/                   # EstimatorViewModel
│   ├── Views/                        # Form, Result screen, History, charts
│   ├── Services/                     # PredictionService (Core ML wrapper)
│   └── LandValueModel.mlmodel        # Bundled trained model
│
├── MLTraining/                       # Python training pipeline
│   ├── load_real_data.py             # Fetches + adapts Ames Housing data
│   ├── preprocessing.py               # Shared feature encoding logic
│   ├── train_model.py                 # Trains + evaluates Linear Regression / Random Forest
│   ├── export_coreml.py               # Converts trained model to Core ML
│   └── data/                          # Training data (CSV)
│
└── docs/
    ├── architecture.svg              # Architecture diagram (see above)
    └── screenshots/                   # App screenshots (see Screenshots section)
```

## Getting Started

### Requirements
- macOS with Xcode 15+
- Python 3.11 or 3.12 (Core ML export tooling doesn't yet support newer Python releases)
- iOS 17+ device or simulator

### Retraining the model
```bash
cd MLTraining
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

python3 load_real_data.py    # fetches real Ames Housing data (requires internet)
python3 train_model.py       # trains + evaluates, saves the winning model
python3 export_coreml.py     # exports to Core ML (.mlmodel)
```

### Running the app
1. Open `LandValueEstimator.xcodeproj` in Xcode
2. Confirm `LandValueModel.mlmodel` is bundled under the app target
3. Build and run on a simulator or device (iOS 17+)

## Known Limitations

- **No vacant land data**: the Ames Housing dataset contains only residential sales. A "Vacant Land" property type option still exists in the UI, but predictions for it are extrapolating from zero real training examples.
- **No geocoding / distance data**: this version of the dataset doesn't include distance-to-amenity features, so "distance to city center," "near school," and "water access" were deliberately removed from the schema rather than faked with placeholder values.
- **Single-market model**: trained entirely on Ames, Iowa sales (2006–2010) — estimates reflect that market, not a generalized national or global model.
- **Global, not per-prediction, feature importance**: see [How Predictions Are Explained](#how-predictions-are-explained) above.

## Roadmap

- [ ] Support additional regional/national datasets (swap-in via the same `load_real_data.py` → `train_model.py` → `export_coreml.py` pipeline)
- [ ] Real vacant-land data, to make that property type option trustworthy
- [ ] TestFlight distribution for beta feedback
- [ ] App icon and launch screen polish

## Contributing

Feedback, bug reports, and feature suggestions are welcome — open an issue or a pull request.

## Acknowledgments

- Ames Housing dataset: De Cock, D. (2011). *Ames, Iowa: Alternative to the Boston Housing Data as an End of Semester Regression Project*. Journal of Statistics Education, 19(3).
