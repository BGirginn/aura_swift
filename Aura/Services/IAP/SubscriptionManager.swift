//
//  SubscriptionManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import Combine

/// Manages premium subscription status and daily scan limits
@MainActor
class SubscriptionManager: ObservableObject {
    
    static let shared = SubscriptionManager()
    
    @Published var isPremium: Bool = false
    @Published var remainingScans: Int = ScanLimits.freeDailyLimit
    
    private let storeKitManager = StoreKitManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        setupObservers()
        checkSubscriptionStatus()
    }
    
    // MARK: - Setup
    
    private func setupObservers() {
        // Listen for purchase notifications
        NotificationCenter.default.publisher(for: .didPurchasePremium)
            .sink { [weak self] _ in
                self?.checkSubscriptionStatus()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Subscription Status
    
    func checkSubscriptionStatus() {
        Task { @MainActor in
            await storeKitManager.updatePurchasedProducts()
            isPremium = storeKitManager.hasActiveSubscription()
            
            // Update UserDefaults
            UserDefaults.standard.set(isPremium, forKey: UserDefaultsKeys.isPremiumUser)
            
            // Update remaining scans
            updateRemainingScans()
        }
    }
    
    // MARK: - Daily Scan Limits
    
    func canScan() -> Bool {
        if isPremium {
            return true // Unlimited for premium
        }
        
        return remainingScans > 0
    }
    
    func recordScan() {
        guard !isPremium else { return }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastScanDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScanDate) as? Date ?? Date.distantPast
        let lastScanDay = Calendar.current.startOfDay(for: lastScanDate)
        
        if today > lastScanDay {
            // New day, reset count
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.dailyScanCount)
            UserDefaults.standard.set(Date(), forKey: UserDefaultsKeys.lastScanDate)
            remainingScans = ScanLimits.freeDailyLimit - 1
        } else {
            // Same day, increment count
            let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dailyScanCount)
            let newCount = currentCount + 1
            UserDefaults.standard.set(newCount, forKey: UserDefaultsKeys.dailyScanCount)
            remainingScans = max(0, ScanLimits.freeDailyLimit - newCount)
        }
    }
    
    private func updateRemainingScans() {
        guard !isPremium else {
            remainingScans = Int.max
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastScanDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScanDate) as? Date ?? Date.distantPast
        let lastScanDay = Calendar.current.startOfDay(for: lastScanDate)
        
        if today > lastScanDay {
            // New day, reset to full limit
            remainingScans = ScanLimits.freeDailyLimit
        } else {
            // Same day, calculate remaining
            let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dailyScanCount)
            remainingScans = max(0, ScanLimits.freeDailyLimit - currentCount)
        }
    }
    
    // MARK: - Premium Features
    
    func hasUnlimitedScans() -> Bool {
        return isPremium
    }
    
    func getRemainingScans() -> Int {
        return remainingScans
    }
}

