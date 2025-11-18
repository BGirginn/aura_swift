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
    @Published var isShowingSettings = false
    @Published var selectedHistoryItem: AuraResult?
    @Published var selectedMode: AuraMode = .faceDetection
    
    // MARK: - Screen Enum
    
    enum Screen: Equatable {
        case onboarding
        case modeSelection
        case quiz
        case camera(AuraMode)
        case result(AuraResult, AuraMode?)
        case history
    }
    
    // MARK: - Navigation Methods
    
    func showOnboarding() {
        currentScreen = .onboarding
    }
    
    func showModeSelection() {
        currentScreen = .modeSelection
    }
    
    func selectMode(_ mode: AuraMode) {
        selectedMode = mode
        switch mode {
        case .quiz:
            currentScreen = .quiz
        case .photoAnalysis, .faceDetection:
            currentScreen = .camera(mode)
        }
    }
    
    func showCamera() {
        currentScreen = .camera(selectedMode)
    }
    
    func showQuiz() {
        currentScreen = .quiz
    }
    
    func showResult(_ result: AuraResult, mode: AuraMode? = nil) {
        currentScreen = .result(result, mode ?? selectedMode)
    }
    
    func showHistory() {
        currentScreen = .history
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
                showModeSelection()
            }
        }
    }
    
    // MARK: - Initialization
    
    init() {
        // Determine initial screen based on onboarding status
        if hasCompletedOnboarding {
            currentScreen = .modeSelection
        } else {
            currentScreen = .onboarding
        }
    }
}

// MARK: - Preview Helper

extension AppCoordinator {
    static var preview: AppCoordinator {
        let coordinator = AppCoordinator()
        coordinator.currentScreen = .modeSelection
        return coordinator
    }
}

