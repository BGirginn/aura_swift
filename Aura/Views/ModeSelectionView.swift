//
//  ModeSelectionView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct ModeSelectionView: View {
    
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack(spacing: LayoutConstants.largePadding) {
                // Header
                headerView
                
                Spacer()
                
                // Mode cards
                VStack(spacing: LayoutConstants.largePadding) {
                    ForEach(AuraMode.allCases, id: \.self) { mode in
                        ModeCard(mode: mode) {
                            coordinator.selectMode(mode)
                        }
                    }
                }
                .padding(.horizontal, LayoutConstants.largePadding)
                
                Spacer()
                
                // Settings button
                Button(action: { coordinator.showSettings() }) {
                    HStack {
                        Image(systemName: "gearshape")
                        Text("Settings")
                    }
                    .foregroundColor(.auraTextSecondary)
                }
                .padding(.bottom, LayoutConstants.largePadding)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            Image(systemName: "sparkles")
                .font(.system(size: 60))
                .foregroundColor(.auraAccent)
            
            Text("Choose Detection Method")
                .font(.title.bold())
                .foregroundColor(.auraText)
            
            Text("Select how you'd like to discover your aura")
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, LayoutConstants.largePadding)
    }
}

// MARK: - Mode Card

struct ModeCard: View {
    
    let mode: AuraMode
    let onTap: () -> Void
    
    private var localizedName: String {
        let language = Locale.current.languageCode ?? "en"
        return language.hasPrefix("tr") ? mode.displayNameTR : mode.displayName
    }
    
    private var localizedDescription: String {
        let language = Locale.current.languageCode ?? "en"
        return language.hasPrefix("tr") ? mode.descriptionTR : mode.description
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LayoutConstants.padding) {
                // Icon
                Image(systemName: mode.icon)
                    .font(.system(size: 40))
                    .foregroundColor(.auraAccent)
                    .frame(width: 60)
                
                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedName)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    Text(localizedDescription)
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Chevron
                Image(systemName: "chevron.right")
                    .foregroundColor(.auraTextSecondary)
            }
            .padding(LayoutConstants.largePadding)
            .background(Color.auraSurface)
            .cornerRadius(LayoutConstants.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct ModeSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        ModeSelectionView(coordinator: AppCoordinator())
    }
}

