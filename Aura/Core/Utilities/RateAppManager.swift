//
//  RateAppManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import StoreKit
import UIKit

/// Handles App Store review prompts and rate app flow
final class RateAppManager {
    
    static let shared = RateAppManager()
    
    private let scanCountKey = "rateApp_scanCount"
    private let lastPromptDateKey = "rateApp_lastPromptDate"
    private let milestoneScans: Set<Int> = [3, 7, 15, 30, 50]
    private let minimumDaysBetweenPrompts: TimeInterval = 60 * 60 * 24 * 30 // 30 days
    
    private init() {}
    
    /// Record that a scan (or meaningful action) finished successfully
    func recordScanCompletion() {
        let newCount = UserDefaults.standard.integer(forKey: scanCountKey) + 1
        UserDefaults.standard.set(newCount, forKey: scanCountKey)
        
        guard shouldPromptReview(for: newCount) else { return }
        requestReview()
    }
    
    /// Request review explicitly (used from Settings)
    func requestReviewFromSettings() {
        requestReview(force: true)
    }
    
    // MARK: - Private Helpers
    
    private func shouldPromptReview(for scanCount: Int) -> Bool {
        guard milestoneScans.contains(scanCount) else { return false }
        
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            if Date().timeIntervalSince(lastPromptDate) < minimumDaysBetweenPrompts {
                return false
            }
        }
        
        return true
    }
    
    private func requestReview(force: Bool = false) {
        DispatchQueue.main.async {
            guard let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                return
            }
            
            if force {
                SKStoreReviewController.requestReview(in: scene)
                UserDefaults.standard.set(Date(), forKey: self.lastPromptDateKey)
                return
            }
            
            let scanCount = UserDefaults.standard.integer(forKey: self.scanCountKey)
            guard self.shouldPromptReview(for: scanCount) else { return }
            
            SKStoreReviewController.requestReview(in: scene)
            UserDefaults.standard.set(Date(), forKey: self.lastPromptDateKey)
        }
    }
}


