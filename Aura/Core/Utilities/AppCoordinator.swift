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
    
    @Published var currentScreen: Screen = .onboarding {
        didSet {
            AnalyticsService.shared.logScreen(currentScreen.analyticsName)
        }
    }
    @Published var isShowingSettings = false
    @Published var selectedHistoryItem: AuraResult?
    @Published var selectedMode: AuraMode = .faceAura
    
    // MARK: - Screen Enum
    
    enum Screen: Equatable {
        case onboarding
        case modeSelection
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
        currentScreen = .camera(mode)
    }
    
    func showCamera() {
        currentScreen = .camera(selectedMode)
    }
    
    func showResult(_ result: AuraResult, mode: AuraMode? = nil) {
        currentScreen = .result(result, mode ?? selectedMode)
    }
    
    func showHistory() {
        currentScreen = .history
        AnalyticsService.shared.logEvent(.historyViewed)
    }
    
    func showSettings() {
        isShowingSettings = true
        AnalyticsService.shared.logEvent(.settingsOpened)
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
                AnalyticsService.shared.logEvent(.onboardingCompleted)
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
        
        AnalyticsService.shared.logScreen(currentScreen.analyticsName)
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

private extension AppCoordinator.Screen {
    var analyticsName: String {
        switch self {
        case .onboarding: return "onboarding"
        case .modeSelection: return "mode_selection"
        case .camera(let mode): return "camera_\(mode.rawValue)"
        case .result(_, let mode): return "result_\(mode?.rawValue ?? "unknown")"
        case .history: return "history"
        }
    }
}

