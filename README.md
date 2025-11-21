# Aura Color Finder - iOS App

A SwiftUI-based iOS application that detects and analyzes aura colors from photos using Vision framework and advanced image processing.

## Project Structure

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern for clean separation of concerns and maintainability.

```
Aura/
├── App/                    # Main app entry point
│   ├── AuraApp.swift      # App entry point
│   └── ContentView.swift  # Root view with navigation
│
├── Core/                   # Core utilities and extensions
│   ├── Extensions/
│   │   └── ColorExtensions.swift
│   ├── Utilities/
│   │   └── AppCoordinator.swift
│   └── Constants/
│       └── Constants.swift
│
├── Models/                 # Data models
│   ├── AuraColor.swift
│   ├── AuraResult.swift
│   └── ScanHistory.swift
│
├── ViewModels/            # Business logic
│   ├── CameraViewModel.swift
│   ├── ResultViewModel.swift
│   └── HistoryViewModel.swift
│
├── Views/                 # UI components
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Camera/
│   │   └── CameraView.swift
│   ├── Result/
│   │   └── ResultView.swift
│   ├── History/
│   │   └── HistoryView.swift
│   └── Settings/
│       └── SettingsView.swift
│
├── Services/              # Business services
│   ├── AuraEngine/
│   │   ├── AuraDetectionService.swift
│   │   └── ColorAnalyzer.swift
│   ├── Storage/
│   │   └── DataManager.swift
│   └── Localization/
│       └── LocalizationService.swift
│
└── Resources/             # Assets and data files
    └── Localization/
        └── aura_comments.json
```

## Setup Instructions

### Prerequisites

- Xcode 14.0 or later
- iOS 15.0 or later
- Swift 5.7 or later

### Installation Steps

1. **Create Xcode Project**
   - Open Xcode
   - File > New > Project
   - Select iOS > App
   - Product Name: "Aura"
   - Interface: SwiftUI
   - Language: Swift
   - Storage: None (we'll add Core Data manually)
   - Save to: `/Users/bgirginn/Desktop/aura_color_swift/`

2. **Add Project Files**
   - Copy all folders from the `Aura/` directory into your Xcode project
   - In Xcode, right-click on project root > Add Files to "Aura"
   - Select all folders and check "Copy items if needed"
   - Ensure "Create groups" is selected
   - Add to target: Aura

3. **Configure Info.plist**
   Add the following privacy permissions:
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to scan your aura</string>
   <key>NSPhotoLibraryUsageDescription</key>
   <string>We need photo library access to select photos for aura scanning</string>
   ```

4. **Add Core Data Model**
   - File > New > File
   - Select "Data Model"
   - Name it "AuraDataModel"
   - Add entity "ScanHistory" with attributes matching `ScanHistory.swift`

5. **Build and Run**
   - Select a simulator or device
   - Press Cmd+R to build and run

## Features

### Sprint 1 (Current)
- ✅ Onboarding flow
- ✅ Camera permission handling
- ✅ Basic camera interface
- ✅ Vision framework face detection
- ✅ Aura color detection (HSV + k-means)
- ✅ Result display with aura rings
- ✅ Scan history
- ✅ Multi-language support (EN, TR)

### Sprint 2 (Planned)
- Premium subscription
- Paywall implementation
- Extended aura descriptions
- Aura trend graphs
- Additional country support (DE, FR, UK)

### Sprint 3 (Planned)
- CoreML integration
- Advanced color analysis
- Social sharing features
- Cloud sync

## Architecture Details

### MVVM Pattern

- **Models**: Pure data structures (AuraColor, AuraResult, ScanHistory)
- **Views**: SwiftUI views that observe ViewModels
- **ViewModels**: Business logic and state management
- **Services**: Reusable business services (detection, storage, localization)

### Key Services

- **AuraDetectionService**: Face detection and aura color analysis
- **ColorAnalyzer**: HSV color space analysis and k-means clustering
- **DataManager**: Core Data wrapper for persistence
- **LocalizationService**: Multi-country aura interpretations

## Color Detection Algorithm

1. Capture image from camera
2. Detect face using Vision framework
3. Expand face region by 50% to get "aura region"
4. Downsample and blur the aura region
5. Convert to HSV color space
6. Apply k-means clustering (k=3) to find dominant colors
7. Map clusters to predefined aura colors
8. Return primary, secondary, and tertiary colors with percentages

## Localization

The app supports multiple countries with culturally adapted aura interpretations:
- 🇺🇸 United States (US)
- 🇹🇷 Turkey (TR)
- 🇬🇧 United Kingdom (UK)
- 🇩🇪 Germany (DE)
- 🇫🇷 France (FR)

Interpretations are stored in `Resources/Localization/aura_comments.json`

## Testing

### Unit Tests
```bash
# Run unit tests
Cmd+U in Xcode
```

### UI Tests
```bash
# Run UI tests
Cmd+U with UI Test target selected
```

## Dependencies

This project uses only native iOS frameworks:
- SwiftUI
- Vision
- CoreData
- AVFoundation
- CoreImage
- Combine

No external dependencies required!

## Contributing

1. Follow the MVVM architecture
2. Use meaningful commit messages
3. Write unit tests for new features
4. Update documentation as needed

## License

Copyright © 2024 Aura Team. All rights reserved.

## Support

For issues or questions, contact: support@auracolor.app

