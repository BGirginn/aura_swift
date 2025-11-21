//
//  Constants.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import SwiftUI

// MARK: - App Constants

enum AppConstants {
    static let appName = "Aura"
    static let version = "1.0.0"
    static let buildNumber = "1"
    
    // Privacy Policy & Terms
    static let privacyPolicyURL = "https://auracolor.app/privacy"
    static let termsOfServiceURL = "https://auracolor.app/terms"
    static let supportEmail = "support@auracolor.app"
}

// MARK: - User Defaults Keys

enum UserDefaultsKeys {
    static let hasCompletedOnboarding = "hasCompletedOnboarding"
    static let selectedCountryCode = "selectedCountryCode"
    static let selectedLanguage = "selectedLanguage"
    static let isPremiumUser = "isPremiumUser"
    static let dailyScanCount = "dailyScanCount"
    static let lastScanDate = "lastScanDate"
    static let hasRequestedReview = "hasRequestedReview"
    static let notificationsEnabled = "notificationsEnabled"
}

// MARK: - Notification Names

extension Notification.Name {
    static let didCompleteScan = Notification.Name("didCompleteScan")
    static let didPurchasePremium = Notification.Name("didPurchasePremium")
    static let didChangeLanguage = Notification.Name("didChangeLanguage")
}

// MARK: - Scan Limits

enum ScanLimits {
    static let freeDailyLimit = 3
    static let premiumDailyLimit = Int.max // Unlimited
}

// MARK: - Animation Constants

enum AnimationConstants {
    static let defaultDuration: Double = 0.3
    static let springResponse: Double = 0.5
    static let springDampingFraction: Double = 0.7
    static let pulseAnimation: Animation = .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
}

// MARK: - Layout Constants

enum LayoutConstants {
    static let cornerRadius: CGFloat = 16
    static let smallCornerRadius: CGFloat = 8
    static let padding: CGFloat = 16
    static let smallPadding: CGFloat = 8
    static let largePadding: CGFloat = 24
    static let buttonHeight: CGFloat = 56
    static let iconSize: CGFloat = 24
    static let largeIconSize: CGFloat = 48
}

// MARK: - Aura Ring Constants

enum AuraRingConstants {
    static let ringWidth: CGFloat = 40
    static let ringSpacing: CGFloat = 10
    static let animationDuration: Double = 2.0
    static let pulseScale: CGFloat = 1.1
}

// MARK: - Camera Constants

enum CameraConstants {
    static let minimumImageSize: CGFloat = 400
    static let photoQuality: CGFloat = 0.8
    static let processingTimeout: TimeInterval = 30
}

// MARK: - Localization

enum SupportedCountries: String, CaseIterable {
    case usa = "US"
    case turkey = "TR"
    case uk = "UK"
    case germany = "DE"
    case france = "FR"
    
    var displayName: String {
        switch self {
        case .usa: return "United States"
        case .turkey: return "Türkiye"
        case .uk: return "United Kingdom"
        case .germany: return "Germany"
        case .france: return "France"
        }
    }
    
    var flag: String {
        switch self {
        case .usa: return "🇺🇸"
        case .turkey: return "🇹🇷"
        case .uk: return "🇬🇧"
        case .germany: return "🇩🇪"
        case .france: return "🇫🇷"
        }
    }
    
    var description: String {
        switch self {
        case .usa: return "US interpretations"
        case .turkey: return "TR yorumları"
        case .uk: return "UK interpretations"
        case .germany: return "DE Interpretationen"
        case .france: return "FR interprétations"
        }
    }
}

// MARK: - IAP Product IDs

enum IAPProductID {
    // Subscriptions
    static let premiumMonthly = "com.auracolorfinder.premium.monthly"
    static let premiumYearly = "com.auracolorfinder.premium.yearly"
    
    // Credit Packs
    static let credits5 = "com.auracolorfinder.credits.5"
    static let credits15 = "com.auracolorfinder.credits.15"
    static let credits40 = "com.auracolorfinder.credits.40"
    
    static var subscriptions: [String] {
        return [premiumMonthly, premiumYearly]
    }
    
    static var creditPacks: [String] {
        return [credits5, credits15, credits40]
    }
    
    static var all: [String] {
        return subscriptions + creditPacks
    }
}

// MARK: - Analytics Events

enum AnalyticsEvent: String {
    case appOpen = "app_open"
    case onboardingCompleted = "onboarding_completed"
    case cameraPermissionGranted = "camera_permission_granted"
    case cameraPermissionDenied = "camera_permission_denied"
    case scanStarted = "scan_started"
    case scanCompleted = "scan_completed"
    case scanFailed = "scan_failed"
    case resultSaved = "result_saved"
    case resultShared = "result_shared"
    case historyViewed = "history_viewed"
    case settingsOpened = "settings_opened"
    case screenView = "screen_view"
    case paywallPresented = "paywall_presented"
    case purchaseStarted = "purchase_started"
    case purchase_success = "purchase_success"
    case purchaseFailed = "purchase_failed"
    case purchase_restored = "purchase_restored"
    case errorOccurred = "error_occurred"
    case userSignedIn = "user_signed_in"
    case userSignedOut = "user_signed_out"
    case settingsChanged = "settings_changed"
}

// MARK: - Error Messages

enum ErrorMessages {
    static let genericError = "An unexpected error occurred. Please try again."
    static let cameraPermissionDenied = "Camera access is required to scan your aura. Please enable it in Settings."
    static let noFaceDetected = "No face detected. Please make sure your face is clearly visible."
    static let processingFailed = "Failed to process the image. Please try again with better lighting."
    static let networkError = "Network connection error. Please check your internet connection."
    static let purchaseFailed = "Purchase failed. Please try again."
    static let dailyLimitReached = "You've reached your daily scan limit. Upgrade to Premium for unlimited scans!"
}

