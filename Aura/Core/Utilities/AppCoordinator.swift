//
//  AppCoordinator.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import Combine

/// Navigation coordinator for the app
class AppCoordinator: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentScreen: Screen = .onboarding
    @Published var isShowingPaywall = false
    @Published var isShowingSettings = false
    @Published var selectedHistoryItem: AuraResult?
    
    // MARK: - Screen Enum
    
    enum Screen: Equatable {
        case onboarding
        case camera
        case result(AuraResult)
        case history
    }
    
    // MARK: - Navigation Methods
    
    func showOnboarding() {
        currentScreen = .onboarding
    }
    
    func showCamera() {
        currentScreen = .camera
    }
    
    func showResult(_ result: AuraResult) {
        currentScreen = .result(result)
    }
    
    func showHistory() {
        currentScreen = .history
    }
    
    func showPaywall() {
        isShowingPaywall = true
    }
    
    func dismissPaywall() {
        isShowingPaywall = false
    }
    
    func showSettings() {
        isShowingSettings = true
    }
    
    func dismissSettings() {
        isShowingSettings = false
    }
    
    func showHistoryDetail(_ item: AuraResult) {
        selectedHistoryItem = item
    }
    
    func dismissHistoryDetail() {
        selectedHistoryItem = nil
    }
    
    // MARK: - Onboarding Status
    
    var hasCompletedOnboarding: Bool {
        get {
            UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKeys.hasCompletedOnboarding)
            if newValue {
                showCamera()
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Determine initial screen based on onboarding status
        if hasCompletedOnboarding {
            currentScreen = .camera
        } else {
            currentScreen = .onboarding
        }
    }
}

// MARK: - Preview Helper

extension AppCoordinator {
    static var preview: AppCoordinator {
        let coordinator = AppCoordinator()
        coordinator.currentScreen = .camera
        return coordinator
    }
}

