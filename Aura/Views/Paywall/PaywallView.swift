//
//  PaywallView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import StoreKit

struct PaywallView: View {
    
    @StateObject private var viewModel = PaywallViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedProduct: Product?
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    // Header
                    headerView
                    
                    // Features List
                    featuresView
                    
                    // Product Cards
                    productsView
                    
                    // Subscribe Button
                    subscribeButton
                    
                    // Restore & Terms
                    footerView
                }
                .padding(.horizontal, LayoutConstants.padding)
                .padding(.vertical, LayoutConstants.largePadding)
            }
        }
        .onAppear {
            AnalyticsService.shared.logEvent(.paywallPresented)
            viewModel.loadProducts()
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.padding) {
            // Crown Icon
            Image(systemName: "crown.fill")
                .font(.system(size: 60))
                .foregroundColor(.yellow)
                .symbolEffect(.pulse, options: .repeating)
            
            Text("Unlock Premium")
                .font(.title.bold())
                .foregroundColor(.auraText)
            
            Text("Get unlimited access to all features")
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
        }
    }
    
    // MARK: - Features
    
    private var featuresView: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            FeatureRow(icon: "infinity", title: "Unlimited Scans", description: "Scan your aura as many times as you want")
            FeatureRow(icon: "doc.text.fill", title: "Detailed Descriptions", description: "Get in-depth insights about your aura")
            FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Aura Trends", description: "Track how your aura changes over time")
            FeatureRow(icon: "xmark.circle.fill", title: "Ad-Free Experience", description: "Enjoy the app without interruptions")
            FeatureRow(icon: "star.fill", title: "Priority Support", description: "Get help when you need it most")
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    // MARK: - Products
    
    private var productsView: some View {
        VStack(spacing: LayoutConstants.padding) {
            if viewModel.isLoading {
                ProgressView()
                    .frame(height: 200)
            } else {
                // Monthly Product
                if let monthly = viewModel.getMonthlyProduct() {
                    ProductCard(
                        product: monthly,
                        isSelected: selectedProduct?.id == monthly.id,
                        onSelect: { selectedProduct = monthly }
                    )
                }
                
                // Yearly Product
                if let yearly = viewModel.getYearlyProduct() {
                    ProductCard(
                        product: yearly,
                        isSelected: selectedProduct?.id == yearly.id,
                        onSelect: { selectedProduct = yearly },
                        savings: viewModel.calculateSavings()
                    )
                }
            }
        }
    }
    
    // MARK: - Subscribe Button
    
    private var subscribeButton: some View {
        Button(action: handleSubscribe) {
            HStack {
                if viewModel.isPurchasing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Start Free Trial")
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: LayoutConstants.buttonHeight)
            .background(selectedProduct != nil ? Color.auraAccent : Color.gray)
            .cornerRadius(LayoutConstants.cornerRadius)
        }
        .disabled(selectedProduct == nil || viewModel.isPurchasing)
    }
    
    // MARK: - Footer
    
    private var footerView: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            Button("Restore Purchases") {
                viewModel.restorePurchases()
            }
            .font(.caption)
            .foregroundColor(.auraTextSecondary)
            
            HStack(spacing: 4) {
                Button("Terms & Conditions") {
                    if let url = URL(string: AppConstants.termsOfServiceURL) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(.auraTextSecondary)
                
                Text("•")
                    .foregroundColor(.auraTextSecondary)
                
                Button("Privacy Policy") {
                    if let url = URL(string: AppConstants.privacyPolicyURL) {
                        UIApplication.shared.open(url)
                    }
                }
                .font(.caption)
                .foregroundColor(.auraTextSecondary)
            }
        }
    }
    
    // MARK: - Actions
    
    private func handleSubscribe() {
        guard let product = selectedProduct else { return }
        viewModel.purchase(product)
        
        // Dismiss after a delay if purchase succeeds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if !viewModel.isPurchasing && viewModel.errorMessage == nil {
                dismiss()
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.padding) {
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
            
            Spacer()
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let isSelected: Bool
    let onSelect: () -> Void
    var savings: String? = nil
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.displayName)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    Text(product.displayPrice)
                        .font(.title3.bold())
                        .foregroundColor(.auraAccent)
                    
                    if let savings = savings {
                        Text(savings)
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .auraAccent : .auraTextSecondary)
            }
            .padding()
            .background(Color.auraSurface)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                    .stroke(isSelected ? Color.auraAccent : Color.clear, lineWidth: 2)
            )
            .cornerRadius(LayoutConstants.cornerRadius)
        }
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

