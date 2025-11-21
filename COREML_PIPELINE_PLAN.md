# Aura CoreML Pipeline Plan

## 1. Goal
Deliver an on-device aura-color classifier that augments the current heuristic pipeline. Model should input a cropped face/full-frame image and output the probability distribution over the `AuraColor` set, plus confidence metadata for UX copy.

## 2. Data Strategy
- **Sources:** Internal capture tool + volunteer submissions (consent required). Target 1,200+ curated samples covering lighting, skin tones, accessories.
- **Labeling:** Use existing aura engine as bootstrap, then run manual review in batches of 50. Store metadata (`lighting`, `mood`, `locale`, `color palette`) in `dataset/labels.jsonl`.
- **Augmentation:** 
  - Geometric: flip, random crop (±10%), rotation (±7º).
  - Photometric: color jitter (hue ±5°, saturation ±10%), gaussian noise, brightness scaling (0.85–1.15).
  - Background blur/synthetic overlays for generalization.
- **Splits:** 70% train / 15% validation / 15% holdout, stratified per aura color.

## 3. Training Pipeline
1. Convert labeled images into 224x224 RGB tensors.
2. Base architecture: MobileNetV3-Small (ImageNet weights) with frozen stem and fine-tuned head.
3. Replace final dense layer with `Dense(numAuraColors, softmax)`.
4. Loss: categorical cross entropy + focal loss (γ=1.5) for minority colors.
5. Optimizer: AdamW (lr 1e-4, weight decay 1e-5), 30 epochs max with early stopping (patience 5).
6. Metrics: accuracy, macro F1, per-class precision/recall. Require ≥78% macro-F1 before ship.
7. Logging via Weights & Biases (project `aura-coreml`).

## 4. Conversion & Packaging
- Export best checkpoint to CoreML using `coremltools` (`compute_units=.all`).
- Quantize to 16-bit float to balance size/perf (~2.5MB target).
- Generate model class `AuraColorClassifier` and wrap in `Aura/Services/CoreML/AuraColorClassifierService.swift`.
- Provide sample unit test verifying output ordering + deterministic results for seeded image fixtures.

## 5. App Integration Roadmap
1. Introduce `AuraDetectionMode.mlPrediction` that runs model on top of current color clusters.
2. Add blending logic: `mlPrimaryColor` vs `colorAnalyzerPrimary`, fallback if confidence <0.4.
3. Extend analytics logging to capture inference confidence distribution (no images).
4. Ship behind remote-config flag (`ml_enabled=false` default).
5. Roll out via TestFlight cohort (min 20 testers) before GA.

## 6. Tooling & Automation
- Create `Scripts/ml/prepare_dataset.py` for preprocessing & augmentations.
- Maintain `Scripts/ml/train.py` orchestrating training with CLI args (epochs, lr, resume checkpoints).
- On CI, lint python scripts and verify CoreML model signature matches `AuraColor` schema.

## 7. Open Items
- Finalize contributor consent form & storage policy.
- Decide on separate models for face vs. full-photo or single multi-task model.
- Evaluate adding `mood` auxiliary output to improve storytelling copy.


