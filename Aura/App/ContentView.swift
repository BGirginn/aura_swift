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
                
            case .modeSelection:
                ModeSelectionView(coordinator: coordinator)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
                
            case .camera(let mode):
                CameraView(coordinator: coordinator, mode: mode)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                
            case .result(let result, let mode):
                ResultView(result: result, coordinator: coordinator, mode: mode)
                    .transition(.scale.combined(with: .opacity))
                
            case .history:
                HistoryView(coordinator: coordinator)
                    .transition(.move(edge: .leading).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.35), value: coordinator.currentScreen)
        .sheet(isPresented: $coordinator.isShowingSettings) {
            SettingsView()
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

