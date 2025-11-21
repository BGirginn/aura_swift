//
//  CountryLanguageView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct CountryLanguageView: View {
    
    @StateObject private var viewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: SettingsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    // Header
                    headerView
                    
                    // Country Selection
                    countrySection
                    
                    // Language Selection
                    languageSection
                }
                .padding(LayoutConstants.padding)
            }
        }
        .navigationTitle("Country & Language")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            Image(systemName: "globe")
                .font(.system(size: 50))
                .foregroundColor(.auraAccent)
            
            Text("Choose Your Region")
                .font(.title2.bold())
                .foregroundColor(.auraText)
            
            Text("Get culturally adapted aura interpretations")
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, LayoutConstants.padding)
    }
    
    // MARK: - Country Section
    
    private var countrySection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            Text("Country")
                .font(.headline)
                .foregroundColor(.auraText)
            
            ForEach(SupportedCountries.allCases, id: \.self) { country in
                CountryRow(
                    country: country,
                    isSelected: viewModel.selectedCountryCode == country.rawValue
                ) {
                    viewModel.updateCountry(country.rawValue)
                }
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    // MARK: - Language Section
    
    private var languageSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            Text("Language")
                .font(.headline)
                .foregroundColor(.auraText)
            
            ForEach(SupportedLanguages.allCases, id: \.self) { language in
                LanguageRow(
                    language: language,
                    isSelected: viewModel.selectedLanguage == language.rawValue
                ) {
                    viewModel.updateLanguage(language.rawValue)
                }
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
}

// MARK: - Country Row

struct CountryRow: View {
    let country: SupportedCountries
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(country.flag)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(country.displayName)
                        .font(.body)
                        .foregroundColor(.auraText)
                    
                    Text(country.description)
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.auraAccent)
                }
            }
            .padding()
            .background(isSelected ? Color.auraAccent.opacity(0.1) : Color.clear)
            .cornerRadius(LayoutConstants.smallCornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Language Row

struct LanguageRow: View {
    let language: SupportedLanguages
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(language.displayName)
                    .font(.body)
                    .foregroundColor(.auraText)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.auraAccent)
                }
            }
            .padding()
            .background(isSelected ? Color.auraAccent.opacity(0.1) : Color.clear)
            .cornerRadius(LayoutConstants.smallCornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Supported Languages

enum SupportedLanguages: String, CaseIterable {
    case english = "en"
    case turkish = "tr"
    case german = "de"
    case french = "fr"
    case ukEnglish = "uk"
    
    var displayName: String {
        switch self {
        case .english: return "English"
        case .turkish: return "Türkçe"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .ukEnglish: return "English (UK)"
        }
    }
}

