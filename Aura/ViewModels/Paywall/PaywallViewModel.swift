//
//  PaywallViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import StoreKit
import Combine

@MainActor
class PaywallViewModel: ObservableObject {
    
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isPurchasing = false
    
    private let storeKitManager = StoreKitManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    init() {
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
                isLoading = false
            }
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) {
        guard !isPurchasing else { return }
        
        isPurchasing = true
        errorMessage = nil
        
        AnalyticsService.shared.logEvent(.purchaseStarted, parameters: [
            "product_id": product.id,
            "price": product.displayPrice
        ])
        
        Task {
            do {
                let success = try await storeKitManager.purchase(product)
                
                await MainActor.run {
                    isPurchasing = false
                    
                    if success {
                        // Purchase successful, subscription manager will update automatically
                        NotificationCenter.default.post(name: .didPurchasePremium, object: nil)
                    } else {
                        errorMessage = "Purchase was cancelled"
                    }
                }
            } catch {
                await MainActor.run {
                    isPurchasing = false
                    errorMessage = error.localizedDescription
                    ErrorHandler.shared.handle(.generic(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Restore
    
    func restorePurchases() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await storeKitManager.restorePurchases()
                
                await MainActor.run {
                    isLoading = false
                    NotificationCenter.default.post(name: .didPurchasePremium, object: nil)
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Failed to restore purchases: \(error.localizedDescription)"
                    ErrorHandler.shared.handle(.generic(error.localizedDescription))
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    func formatPrice(_ product: Product) -> String {
        return product.displayPrice
    }
    
    func getMonthlyProduct() -> Product? {
        return products.first { $0.id == IAPProductID.premiumMonthly }
    }
    
    func getYearlyProduct() -> Product? {
        return products.first { $0.id == IAPProductID.premiumYearly }
    }
    
    func calculateSavings() -> String? {
        guard let monthly = getMonthlyProduct(),
              let yearly = getYearlyProduct() else {
            return nil
        }
        
        let monthlyPrice = monthly.price
        let yearlyPrice = yearly.price
        let monthlyTotal = monthlyPrice * 12
        
        if monthlyTotal > yearlyPrice {
            let savings = monthlyTotal - yearlyPrice
            let percentage = Int((savings / monthlyTotal) * 100)
            return "Save \(percentage)%"
        }
        
        return nil
    }
}

