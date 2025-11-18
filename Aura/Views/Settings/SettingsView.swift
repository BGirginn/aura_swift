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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.auraBackground.ignoresSafeArea()
                
                List {
                    // Account Section
                    Section {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.title)
                                .foregroundColor(.auraAccent)
                            
                            VStack(alignment: .leading) {
                                Text("Account Status")
                                    .font(.headline)
                                Text(isPremium ? "Premium Member" : "Free User")
                                    .font(.caption)
                                    .foregroundColor(.auraTextSecondary)
                            }
                            
                            Spacer()
                            
                            if !isPremium {
                                Button("Upgrade") {
                                    // Show paywall
                                }
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.auraAccent)
                                .cornerRadius(LayoutConstants.smallCornerRadius)
                            } else {
                                Image(systemName: "crown.fill")
                                    .foregroundColor(.yellow)
                            }
                        }
                    } header: {
                        Text("Account")
                    }
                    .listRowBackground(Color.auraSurface)
                    
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
                .scrollContentBackground(.hidden)
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
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

