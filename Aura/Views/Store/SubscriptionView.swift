//
//  SubscriptionView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) var dismiss
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    // Header
                    headerView
                    
                    // Features
                    featuresView
                    
                    // Subscription Options
                    if !viewModel.products.isEmpty {
                        subscriptionOptionsView
                    } else if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .auraAccent))
                    }
                    
                    // Restore Button
                    restoreButton
                }
                .padding(LayoutConstants.padding)
            }
        }
        .navigationTitle("Premium")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.loadProducts()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.auraAccent)
            
            Text("Unlock Premium")
                .font(.title.bold())
                .foregroundColor(.auraText)
            
            Text("Get unlimited scans and exclusive features")
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, LayoutConstants.padding)
    }
    
    // MARK: - Features
    
    private var featuresView: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            FeatureRow(icon: "infinity", title: "Unlimited Scans", description: "Scan as many times as you want")
            FeatureRow(icon: "sparkles", title: "Advanced Analysis", description: "Get detailed aura breakdowns")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Trend Tracking", description: "See how your aura changes over time")
            FeatureRow(icon: "star.fill", title: "Priority Support", description: "Get help when you need it")
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    // MARK: - Subscription Options
    
    private var subscriptionOptionsView: some View {
        VStack(spacing: LayoutConstants.padding) {
            ForEach(viewModel.products, id: \.id) { product in
                SubscriptionOptionCard(
                    product: product,
                    isPurchasing: viewModel.isPurchasing,
                    onPurchase: {
                        viewModel.purchase(product)
                    }
                )
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

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: LayoutConstants.padding) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.auraAccent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.auraText)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
            }
        }
    }
}

// MARK: - Subscription Option Card

struct SubscriptionOptionCard: View {
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    private var isYearly: Bool {
        product.id.contains("yearly")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    if isYearly {
                        Text("Best Value")
                            .font(.caption)
                            .foregroundColor(.green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Text(product.displayPrice)
                    .font(.title2.bold())
                    .foregroundColor(.auraAccent)
            }
            
            if isYearly {
                Text("Save 20% compared to monthly")
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
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

