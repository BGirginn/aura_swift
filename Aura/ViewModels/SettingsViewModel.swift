//
//  SettingsViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import Combine
import SwiftUI

class SettingsViewModel: ObservableObject {
    
    @Published var selectedCountryCode: String
    @Published var selectedLanguage: String
    @Published var isPremium: Bool
    @Published var notificationsEnabled: Bool
    @Published var analyticsEnabled: Bool
    @Published var savePhotos: Bool
    
    private let authService: AuthService
    private let subscriptionManager: SubscriptionManager
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = .shared,
         subscriptionManager: SubscriptionManager = .shared) {
        self.authService = authService
        self.subscriptionManager = subscriptionManager
        
        // Load from UserDefaults
        selectedCountryCode = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCountryCode) ?? Locale.current.region?.identifier ?? "US"
        selectedLanguage = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedLanguage) ?? Locale.current.languageCode ?? "en"
        isPremium = subscriptionManager.isPremium
        notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        analyticsEnabled = true // Default enabled
        savePhotos = true // Default enabled
        
        setupBindings()
    }
    
    private func setupBindings() {
        subscriptionManager.$isPremium
            .assign(to: &$isPremium)
    }
    
    // MARK: - Actions
    
    func updateCountry(_ countryCode: String) {
        selectedCountryCode = countryCode
        UserDefaults.standard.set(countryCode, forKey: UserDefaultsKeys.selectedCountryCode)
        authService.updateUserProfile(countryCode: countryCode, languageCode: selectedLanguage)
        NotificationCenter.default.post(name: .didChangeLanguage, object: nil)
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: ["setting": "country", "value": countryCode])
    }
    
    func updateLanguage(_ languageCode: String) {
        selectedLanguage = languageCode
        UserDefaults.standard.set(languageCode, forKey: UserDefaultsKeys.selectedLanguage)
        authService.updateUserProfile(countryCode: selectedCountryCode, languageCode: languageCode)
        NotificationCenter.default.post(name: .didChangeLanguage, object: nil)
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: ["setting": "language", "value": languageCode])
    }
    
    func toggleNotifications(_ enabled: Bool) {
        notificationsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: UserDefaultsKeys.notificationsEnabled)
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: ["setting": "notifications", "value": enabled])
    }
    
    func toggleAnalytics(_ enabled: Bool) {
        analyticsEnabled = enabled
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: ["setting": "analytics", "value": enabled])
    }
    
    func toggleSavePhotos(_ enabled: Bool) {
        savePhotos = enabled
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: ["setting": "savePhotos", "value": enabled])
    }
    
    var appVersion: String {
        "\(AppConstants.version) (\(AppConstants.buildNumber))"
    }
}

