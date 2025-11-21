//
//  AuraApp.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

@main
struct AuraApp: App {
    
    @StateObject private var coordinator = AppCoordinator()
    @StateObject private var themeManager = ThemeManager.shared
    
    init() {
        AnalyticsService.shared.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .environmentObject(themeManager)
                .preferredColorScheme(themeManager.colorScheme)
        }
    }
}

