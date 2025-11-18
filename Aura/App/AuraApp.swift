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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(coordinator)
                .preferredColorScheme(.dark)
        }
    }
}

