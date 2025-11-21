//
//  SettingsView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var selectedCountry: SupportedCountries = .usa
    @State private var selectedLanguage: String = "en"
    @State private var notificationsEnabled = false
    @State private var isPremium = false
    @State private var debugMode = false
    @State private var showNotificationAlert = false
    @State private var notificationAlertMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.auraBackground.ignoresSafeArea()
                
                List {
                    // Account Section
                    // Account section removed for base version
                    
                    // Region Settings
                    Section {
                        Picker("Country/Region", selection: $selectedCountry) {
                            ForEach(SupportedCountries.allCases, id: \.self) { country in
                                HStack {
                                    Text(country.flag)
                                    Text(country.displayName)
                                }
                                .tag(country)
                            }
                        }
                        .onChange(of: selectedCountry) { newValue in
                            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKeys.selectedCountryCode)
                            LocalizationService.shared.setCountryCode(newValue.rawValue)
                            AnalyticsService.shared.setUserProperty(newValue.rawValue, for: "country")
                            print("✅ Country changed to: \(newValue.displayName)")
                        }
                        
                        Picker("Language", selection: $selectedLanguage) {
                            Text("English 🇺🇸").tag("en")
                            Text("Türkçe 🇹🇷").tag("tr")
                        }
                        .onChange(of: selectedLanguage) { newValue in
                            LocalizationService.shared.setLanguage(newValue)
                            print("✅ Language changed to: \(newValue)")
                        }
                    } header: {
                        Text("Localization")
                    } footer: {
                        Text("Aura interpretations will be adapted to your selected region and language")
                    }
                    .listRowBackground(Color.auraSurface)
                    
                    // Notifications
                    Section {
                        Toggle("Daily Reminders", isOn: $notificationsEnabled)
                            .onChange(of: notificationsEnabled) { newValue in
                                handleNotificationToggle(isOn: newValue)
                            }
                    } header: {
                        Text("Notifications")
                    } footer: {
                        Text("Receive daily reminders to scan your aura")
                    }
                    .listRowBackground(Color.auraSurface)
                    
                    // Debug Mode (Debug builds only)
                    #if DEBUG
                    Section {
                        Toggle("Debug/Test Mode", isOn: $debugMode)
                            .onChange(of: debugMode) { newValue in
                                DebugManager.shared.isDebugMode = newValue
                            }
                    } header: {
                        Text("Developer")
                    } footer: {
                        Text("Enable test buttons to quickly test different aura colors without camera")
                    }
                    .listRowBackground(Color.auraSurface)
                    #endif
                    
                    // About
                    Section {
                        NavigationLink(destination: PrivacyPolicyView()) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                        }
                        
                        NavigationLink(destination: TermsOfServiceView()) {
                            Label("Terms of Service", systemImage: "doc.text")
                        }
                        
                        HStack {
                            Label("Version", systemImage: "info.circle")
                            Spacer()
                            Text(AppConstants.version)
                                .foregroundColor(.auraTextSecondary)
                        }
                    } header: {
                        Text("About")
                    }
                    .listRowBackground(Color.auraSurface)
                    
                    // Support
                    Section {
                        Link(destination: URL(string: "mailto:\(AppConstants.supportEmail)")!) {
                            Label("Contact Support", systemImage: "envelope")
                        }
                        
                        Button(action: {
                            RateAppManager.shared.requestReviewFromSettings()
                        }) {
                            Label("Rate App", systemImage: "star.fill")
                        }
                    } header: {
                        Text("Support")
                    }
                    .listRowBackground(Color.auraSurface)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.auraAccent)
                }
            }
        }
        .onAppear {
            loadSettings()
        }
        .alert("Notifications", isPresented: $showNotificationAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(notificationAlertMessage)
        }
    }
    
    private func loadSettings() {
        if let countryCode = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCountryCode),
           let country = SupportedCountries(rawValue: countryCode) {
            selectedCountry = country
        }
        
        selectedLanguage = LocalizationService.shared.getCurrentLanguage()
        
        isPremium = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremiumUser)
        notificationsEnabled = UserDefaults.standard.bool(forKey: UserDefaultsKeys.notificationsEnabled)
        
        #if DEBUG
        debugMode = DebugManager.shared.isDebugMode
        #endif
    }
    
    private func handleNotificationToggle(isOn: Bool) {
        if isOn {
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    NotificationManager.shared.updateDailyReminder(enabled: true)
                    UserDefaults.standard.set(true, forKey: UserDefaultsKeys.notificationsEnabled)
                    notificationAlertMessage = "Daily reminders enabled. You'll receive a notification each morning."
                    showNotificationAlert = true
                } else {
                    notificationsEnabled = false
                    notificationAlertMessage = "Notifications are disabled for Aura. You can enable them in iOS Settings."
                    showNotificationAlert = true
                }
            }
        } else {
            NotificationManager.shared.updateDailyReminder(enabled: false)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.notificationsEnabled)
            notificationAlertMessage = "Daily reminders turned off."
            showNotificationAlert = true
        }
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

