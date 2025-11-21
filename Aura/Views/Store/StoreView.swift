//
//  StoreView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import StoreKit

struct StoreView: View {
    
    @StateObject private var viewModel = StoreViewModel()
    @Environment(\.dismiss) var dismiss
    @StateObject private var authService = AuthService.shared
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    // Header
                    headerView
                    
                    // Current Status
                    currentStatusView
                    
                    // Subscriptions
                    if !viewModel.subscriptions.isEmpty {
                        subscriptionsSection
                    }
                    
                    // Credit Packs
                    if !viewModel.creditPacks.isEmpty {
                        creditPacksSection
                    }
                    
                    // Restore Purchases
                    restoreButton
                }
                .padding(LayoutConstants.padding)
            }
        }
        .navigationTitle("Store")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadProducts()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            Image(systemName: "storefront")
                .font(.system(size: 50))
                .foregroundColor(.auraAccent)
            
            Text("Aura Store")
                .font(.title2.bold())
                .foregroundColor(.auraText)
            
            Text("Unlock premium features and credits")
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, LayoutConstants.padding)
    }
    
    // MARK: - Current Status
    
    private var currentStatusView: some View {
        VStack(spacing: LayoutConstants.padding) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Premium Status")
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                    
                    Text(authService.currentUser?.hasPremium == true ? "Premium Active" : "Free")
                        .font(.headline)
                        .foregroundColor(.auraText)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Credits")
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                    
                    Text("\(authService.currentUser?.credits ?? 0)")
                        .font(.headline)
                        .foregroundColor(.auraAccent)
                }
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    // MARK: - Subscriptions Section
    
    private var subscriptionsSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            Text("Premium Subscriptions")
                .font(.headline)
                .foregroundColor(.auraText)
            
            ForEach(viewModel.subscriptions, id: \.id) { product in
                SubscriptionProductCard(
                    product: product,
                    isPurchasing: viewModel.isPurchasing,
                    onPurchase: {
                        viewModel.purchase(product)
                    }
                )
            }
        }
    }
    
    // MARK: - Credit Packs Section
    
    private var creditPacksSection: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            Text("Credit Packs")
                .font(.headline)
                .foregroundColor(.auraText)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: LayoutConstants.padding) {
                ForEach(viewModel.creditPacks, id: \.id) { product in
                    CreditPackCard(
                        product: product,
                        isPurchasing: viewModel.isPurchasing,
                        onPurchase: {
                            viewModel.purchase(product)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            viewModel.restorePurchases()
        }) {
            Text("Restore Purchases")
                .font(.subheadline)
                .foregroundColor(.auraAccent)
        }
        .padding()
    }
}

// MARK: - Subscription Product Card

struct SubscriptionProductCard: View {
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    Text(product.description)
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title3.bold())
                    .foregroundColor(.auraAccent)
            }
            
            Button(action: onPurchase) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Subscribe")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: LayoutConstants.buttonHeight)
            .background(Color.auraAccent)
            .cornerRadius(LayoutConstants.cornerRadius)
            .disabled(isPurchasing)
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
}

// MARK: - Credit Pack Card

struct CreditPackCard: View {
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    private var creditAmount: Int {
        // Extract from product ID
        if let range = product.id.range(of: #"\d+"#, options: .regularExpression) {
            return Int(product.id[range]) ?? 0
        }
        return 0
    }
    
    var body: some View {
        VStack(spacing: LayoutConstants.padding) {
            Text("\(creditAmount)")
                .font(.title.bold())
                .foregroundColor(.auraAccent)
            
            Text("Credits")
                .font(.caption)
                .foregroundColor(.auraTextSecondary)
            
            Text(product.displayPrice)
                .font(.headline)
                .foregroundColor(.auraText)
            
            Button(action: onPurchase) {
                if isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Buy")
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.auraAccent)
            .cornerRadius(LayoutConstants.smallCornerRadius)
            .disabled(isPurchasing)
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
}

