# Firebase Setup Guide

## Overview
This app uses Firebase Analytics and Remote Config for tracking and feature flags. The implementation is already in place with conditional compilation - Firebase will work automatically once the SDK is added.

## Setup Steps

### 1. Install Firebase SDK

#### Option A: Swift Package Manager (Recommended)
1. In Xcode, go to **File > Add Package Dependencies**
2. Enter: `https://github.com/firebase/firebase-ios-sdk`
3. Select these products:
   - `FirebaseAnalytics`
   - `FirebaseRemoteConfig`
   - `FirebaseCrashlytics` (optional)
4. Click **Add Package**

#### Option B: CocoaPods
Add to `Podfile`:
```ruby
pod 'Firebase/Analytics'
pod 'Firebase/RemoteConfig'
pod 'Firebase/Crashlytics'  # Optional
```

### 2. Download GoogleService-Info.plist
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing
3. Add iOS app with bundle ID: `com.auracolorfinder.app`
4. Download `GoogleService-Info.plist`
5. Add to Xcode project root (drag into project, ensure "Copy items if needed" is checked)
6. Ensure it's added to the Aura target

### 3. Configure Firebase in App
The `AnalyticsService` is already configured to automatically use Firebase when available. No code changes needed!

### 4. Test Firebase Integration
1. Build and run the app
2. Check Firebase Console > Analytics > DebugView
3. You should see events appearing in real-time

## Current Implementation

### AnalyticsService
- ✅ Already configured with conditional compilation
- ✅ Falls back to console logging if Firebase not linked
- ✅ All events are logged through `AnalyticsService.shared.logEvent()`

### Events Tracked
- `app_open`
- `onboarding_completed`
- `scan_started`
- `scan_completed`
- `scan_failed`
- `purchase_started`
- `purchase_success`
- `purchase_failed`
- `error_occurred`
- And more...

### Remote Config Setup
1. In Firebase Console, go to **Remote Config**
2. Add parameters as needed:
   - `ml_enabled` (boolean) - Enable CoreML model
   - `daily_scan_limit` (number) - Override daily limit
   - `feature_flags` (JSON) - Feature toggles

## Notes
- The app works **without Firebase** - it just logs to console
- Firebase is **optional** - add it when ready for production
- All analytics calls are already in place and will work automatically once Firebase is added

