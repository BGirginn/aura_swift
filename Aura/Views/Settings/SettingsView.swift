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
    @State private var notificationsEnabled = false
    @State private var isPremium = false
    @State private var debugMode = false
    
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
                    } header: {
                        Text("Localization")
                    } footer: {
                        Text("Aura interpretations will be adapted to your selected region")
                    }
                    .listRowBackground(Color.auraSurface)
                    
                    // Notifications
                    Section {
                        Toggle("Daily Reminders", isOn: $notificationsEnabled)
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
                        NavigationLink(destination: Text("Privacy Policy")) {
                            Label("Privacy Policy", systemImage: "hand.raised")
                        }
                        
                        NavigationLink(destination: Text("Terms of Service")) {
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
                        
                        Button(action: {}) {
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
    }
    
    private func loadSettings() {
        if let countryCode = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCountryCode),
           let country = SupportedCountries(rawValue: countryCode) {
            selectedCountry = country
        }
        
        isPremium = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremiumUser)
        
        #if DEBUG
        debugMode = DebugManager.shared.isDebugMode
        #endif
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

