//
//  OnboardingViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import SwiftUI
import Combine

@MainActor
class OnboardingViewModel: ObservableObject {
    
    @Published var currentPage = 0
    @Published var hasCompletedOnboarding = false
    
    let totalPages = 3
    
    var canGoNext: Bool {
        currentPage < totalPages - 1
    }
    
    var canGoPrevious: Bool {
        currentPage > 0
    }
    
    var progress: Double {
        Double(currentPage + 1) / Double(totalPages)
    }
    
    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hasCompletedOnboarding)
    }
    
    func nextPage() {
        guard canGoNext else { return }
        currentPage += 1
    }
    
    func previousPage() {
        guard canGoPrevious else { return }
        currentPage -= 1
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hasCompletedOnboarding)
        AnalyticsService.shared.logEvent(.onboardingCompleted)
    }
    
    func skipOnboarding() {
        completeOnboarding()
    }
}

