//
//  StoreKitManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import StoreKit

/// Manages in-app purchases and StoreKit operations
@MainActor
class StoreKitManager: NSObject, ObservableObject {
    
    static let shared = StoreKitManager()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var updateListenerTask: Task<Void, Error>?
    
    private override init() {
        super.init()
        updateListenerTask = listenForTransactions()
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Product Loading
    
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let productIDs = IAPProductID.all
            let storeProducts = try await Product.products(for: productIDs)
            
            products = storeProducts.sorted { $0.id < $1.id }
            isLoading = false
        } catch {
            errorMessage = "Failed to load products: \(error.localizedDescription)"
            isLoading = false
            ErrorHandler.shared.handle(.generic(error.localizedDescription))
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws -> Bool {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                
                await updatePurchasedProducts()
                
                AnalyticsService.shared.logEvent(.purchase_success, parameters: [
                    "product_id": product.id,
                    "price": product.displayPrice
                ])
                
                NotificationCenter.default.post(name: .didPurchasePremium, object: nil)
                
                return true
                
            case .userCancelled:
                AnalyticsService.shared.logEvent(.purchaseFailed, parameters: [
                    "reason": "user_cancelled"
                ])
                return false
                
            case .pending:
                AnalyticsService.shared.logEvent(.purchaseFailed, parameters: [
                    "reason": "pending"
                ])
                return false
                
            @unknown default:
                return false
            }
        } catch {
            ErrorHandler.shared.handle(.generic(error.localizedDescription))
            AnalyticsService.shared.logEvent(.purchaseFailed, parameters: [
                "error": error.localizedDescription
            ])
            throw error
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async throws {
        try await AppStore.sync()
        await updatePurchasedProducts()
        
        AnalyticsService.shared.logEvent(.purchase_restored)
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updatePurchasedProducts()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .autoRenewable {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Failed to verify transaction: \(error)")
            }
        }
        
        await MainActor.run {
            purchasedProductIDs = purchasedIDs
        }
    }
    
    // MARK: - Check Purchase Status
    
    func isProductPurchased(_ productID: String) -> Bool {
        return purchasedProductIDs.contains(productID)
    }
    
    func hasActiveSubscription() -> Bool {
        return !purchasedProductIDs.isEmpty
    }
}

// MARK: - Store Errors

enum StoreError: Error {
    case failedVerification
    case productNotFound
    case purchaseFailed
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Transaction verification failed"
        case .productNotFound:
            return "Product not found"
        case .purchaseFailed:
            return "Purchase failed"
        }
    }
}

