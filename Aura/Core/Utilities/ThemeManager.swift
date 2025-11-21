//
//  ThemeManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import SwiftUI
import Combine

/// Manages app theme (light/dark/system)
class ThemeManager: ObservableObject {
    
    static let shared = ThemeManager()
    
    @Published var colorScheme: ColorScheme?
    @Published var themePreference: ThemePreference = .system
    
    enum ThemePreference: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "Light"
            case .dark: return "Dark"
            case .system: return "System"
            }
        }
    }
    
    private let userDefaultsKey = "themePreference"
    
    private init() {
        loadThemePreference()
        updateColorScheme()
        
        // Listen to system theme changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(systemThemeChanged),
            name: .systemThemeChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Theme Management
    
    func setTheme(_ preference: ThemePreference) {
        themePreference = preference
        UserDefaults.standard.set(preference.rawValue, forKey: userDefaultsKey)
        updateColorScheme()
        
        AnalyticsService.shared.logEvent(.settingsChanged, parameters: [
            "setting": "theme",
            "value": preference.rawValue
        ])
    }
    
    private func loadThemePreference() {
        if let saved = UserDefaults.standard.string(forKey: userDefaultsKey),
           let preference = ThemePreference(rawValue: saved) {
            themePreference = preference
        }
    }
    
    private func updateColorScheme() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch self.themePreference {
            case .light:
                self.colorScheme = .light
            case .dark:
                self.colorScheme = .dark
            case .system:
                // Use system preference
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    self.colorScheme = windowScene.windows.first?.traitCollection.userInterfaceStyle == .dark ? .dark : .light
                } else {
                    self.colorScheme = .dark // Default fallback
                }
            }
        }
    }
    
    @objc private func systemThemeChanged() {
        if themePreference == .system {
            updateColorScheme()
        }
    }
}

// MARK: - Notification Extension

extension Notification.Name {
    static let systemThemeChanged = Notification.Name("systemThemeChanged")
}

