//
//  ContentView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            // Main screen based on navigation state
            switch coordinator.currentScreen {
            case .onboarding:
                OnboardingView(coordinator: coordinator)
                    .transition(.opacity)
                
            case .camera:
                CameraView(coordinator: coordinator)
                    .transition(.opacity)
                
            case .result(let result):
                ResultView(result: result, coordinator: coordinator)
                    .transition(.opacity)
                
            case .history:
                HistoryView(coordinator: coordinator)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: coordinator.currentScreen)
        .sheet(isPresented: $coordinator.isShowingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $coordinator.isShowingPaywall) {
            PaywallView(coordinator: coordinator)
        }
    }
}

// MARK: - Paywall View (Placeholder)

struct PaywallView: View {
    
    @StateObject var coordinator: AppCoordinator
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack(spacing: LayoutConstants.largePadding) {
                // Header
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.auraTextSecondary)
                    }
                }
                .padding()
                
                Spacer()
                
                // Crown icon
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                Text("Unlock Premium")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.auraText)
                
                Text("Get unlimited access to all features")
                    .font(.title3)
                    .foregroundColor(.auraTextSecondary)
                    .multilineTextAlignment(.center)
                
                // Features
                VStack(alignment: .leading, spacing: LayoutConstants.padding) {
                    ForEach(PremiumFeatures.allCases, id: \.self) { feature in
                        HStack {
                            Image(systemName: feature.icon)
                                .foregroundColor(.auraAccent)
                                .frame(width: 30)
                            Text(feature.displayName)
                                .foregroundColor(.auraText)
                            Spacer()
                        }
                    }
                }
                .padding(LayoutConstants.largePadding)
                .background(Color.auraSurface)
                .cornerRadius(LayoutConstants.cornerRadius)
                .padding(.horizontal, LayoutConstants.largePadding)
                
                Spacer()
                
                // Subscribe button
                Button(action: {}) {
                    VStack(spacing: 8) {
                        Text("Start Free Trial")
                            .font(.headline)
                        Text("Then $4.99/month")
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutConstants.buttonHeight)
                    .background(Color.auraAccent)
                    .cornerRadius(LayoutConstants.cornerRadius)
                }
                .padding(.horizontal, LayoutConstants.largePadding)
                
                Text("Terms & Conditions")
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
                    .padding(.bottom)
            }
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppCoordinator())
    }
}

