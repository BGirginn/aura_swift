# Aura TestFlight & QA Checklist

## 1. Build Preparation
- [ ] Increment `CFBundleShortVersionString` / `CFBundleVersion`.
- [ ] Run `xcodebuild -scheme Aura -configuration Release -destination 'generic/platform=iOS' clean archive`.
- [ ] Export `.ipa` via `xcodebuild -exportArchive` or Xcode Organizer.
- [ ] Validate archive (no warnings/errors) before upload.

## 2. Pre-upload Verification
- [ ] `swiftlint` (if enabled) + `xcodebuild test` for unit/UI tests.
- [ ] Manual sanity run on iPhone 14/15 simulator (camera mocked) and at least one physical device for camera/gallery permissions.
- [ ] Confirm App Icon, onboarding flow, Settings navigation, notifications prompt.
- [ ] Ensure Privacy Policy & Terms screens render correctly.

## 3. App Store Connect Upload
- [ ] Use `xcrun altool` or Xcode Organizer to upload `.ipa`.
- [ ] Associate build with the correct TestFlight version.
- [ ] Fill “What to Test” section (bullet list below).

**What to Test (initial round)**
1. Multi-mode scans: Face Aura, Photo Analysis, Quiz results.
2. Gallery import edge cases (panorama, screenshots).
3. Localization toggles (TR, US, DE, FR, UK).
4. History trend card accuracy vs. actual scans.
5. Notifications toggle state + reminder delivery.

## 4. Tester Groups
- **Internal (3 people)** – verify developer checklist, run through debug tools.
- **Friends & Family (10 people)** – diverse devices (iPhone 12–15, SE Gen 2–3).
- **Localized testers** – at least 1 native speaker per supported locale.

## 5. QA Matrix
| Feature | Pass Criteria | Device Matrix |
| --- | --- | --- |
| Camera Scan | Opens camera, detects face, returns aura in <5s | iPhone 14 Pro, iPhone 13, iPhone SE |
| Gallery Scan | Selects photo, processes without crash | Same as above + iPhone 15 |
| Quiz Mode | 10 questions load, result shares | All devices |
| History Trend | Stats reflect manual counts | Primary tester |
| Notifications | Reminder delivered within 5 mins of scheduled time | Physical device only |

## 6. Post-Upload
- [ ] Collect tester feedback via shared Notion/Sheet (include device, OS, build, repro steps).
- [ ] Triage issues into “Blocker / Major / Minor”.
- [ ] Recycle builds until all blocker/major issues closed.

## 7. Release Gate
- [ ] Analytics dashboards (Events + Crash reports) monitored for at least 48h after TestFlight push.
- [ ] Confirm no P0 bugs open.
- [ ] Prepare App Store metadata (see `APP_STORE_ASSETS.md`) before submitting for review.

