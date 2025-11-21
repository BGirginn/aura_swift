//
//  StoreViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import StoreKit
import Combine

@MainActor
class StoreViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var creditPacks: [Product] = []
    @Published var subscriptions: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPurchasing = false
    
    private let storeKitManager: StoreKitManager
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(storeKitManager: StoreKitManager = .shared,
         authService: AuthService = .shared) {
        self.storeKitManager = storeKitManager
        self.authService = authService
        loadProducts()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            await storeKitManager.loadProducts()
            
            await MainActor.run {
                products = storeKitManager.products
                creditPacks = products.filter { $0.id.contains("credits") }
                subscriptions = products.filter { $0.id.contains("premium") }
                isLoading = false
            }
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        errorMessage = nil
        
        Task {
            do {
                let success = try await storeKitManager.purchase(product)
                
                await MainActor.run {
                    isPurchasing = false
                    
                    if success {
                        if product.id.contains("credits") {
                            // Add credits based on product ID
                            let credits = extractCreditsFromProductID(product.id)
                            authService.addCredits(credits)
                            AnalyticsService.shared.logEvent(.purchase_success, parameters: [
                                "product_id": product.id,
                                "type": "credits",
                                "amount": credits
                            ])
                        } else {
                            // Subscription handled by SubscriptionManager
                            AnalyticsService.shared.logEvent(.purchase_success, parameters: [
                                "product_id": product.id,
                                "type": "subscription"
                            ])
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    AnalyticsService.shared.logEvent(.purchaseFailed, parameters: [
                        "product_id": product.id,
                        "error": error.localizedDescription
                    ])
                }
            }
        }
    }
    
    func restorePurchases() {
        isLoading = true
        
        Task {
            do {
                try await storeKitManager.restorePurchases()
                await MainActor.run {
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    // MARK: - Helpers
    
    private func extractCreditsFromProductID(_ productID: String) -> Int {
        // Extract number from product ID like "com.aura.credits.5"
        if let range = productID.range(of: #"\d+"#, options: .regularExpression) {
            return Int(productID[range]) ?? 0
        }
        return 0
    }
}

