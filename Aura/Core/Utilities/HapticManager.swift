//
//  HapticManager.swift
//  Aura
//
//  Created by Aura Team
//

import UIKit

/// Manager for haptic feedback throughout the app
class HapticManager {
    
    static let shared = HapticManager()
    
    private init() {}
    
    // MARK: - Impact Feedback
    
    func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    // MARK: - Notification Feedback
    
    func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    // MARK: - Selection Feedback
    
    func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
    
    // MARK: - Context-Specific Haptics
    
    func scanStarted() {
        medium()
    }
    
    func scanCompleted() {
        success()
    }
    
    func scanFailed() {
        error()
    }
    
    func buttonTap() {
        light()
    }
}

