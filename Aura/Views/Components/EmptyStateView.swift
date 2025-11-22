//
//  EmptyStateView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

/// Reusable empty state view with illustrations and CTAs
struct EmptyStateView: View {
    
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    @State private var isAnimating = false
    
    init(
        icon: String = "sparkles",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Spacer()
            
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.auraAccent.opacity(0.3), Color.auraAccent.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundColor(.auraAccent)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
            }
            
            // Title
            Text(title)
                .font(.title2.bold())
                .foregroundColor(.auraText)
                .multilineTextAlignment(.center)
            
            // Message
            Text(message)
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutConstants.largePadding)
            
            // Action Button
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, LayoutConstants.largePadding)
                        .padding(.vertical, LayoutConstants.padding)
                        .background(Color.auraAccent)
                        .cornerRadius(LayoutConstants.cornerRadius)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Predefined Empty States

extension EmptyStateView {
    static func historyEmpty(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "clock.arrow.circlepath",
            title: NSLocalizedString("history.empty.title", value: "No Scans Yet", comment: ""),
            message: NSLocalizedString("history.empty.message", value: "Your scan history will appear here", comment: ""),
            actionTitle: NSLocalizedString("history.startScanning", value: "Start Scanning", comment: ""),
            action: action
        )
    }
    
    static func favoritesEmpty(action: @escaping () -> Void) -> EmptyStateView {
        EmptyStateView(
            icon: "star.fill",
            title: NSLocalizedString("history.empty.favorites", value: "No Favorites Yet", comment: ""),
            message: NSLocalizedString("history.empty.favoritesMessage", value: "Mark scans as favorite to see them here", comment: ""),
            actionTitle: NSLocalizedString("history.startScanning", value: "Start Scanning", comment: ""),
            action: action
        )
    }
    
    static func searchEmpty() -> EmptyStateView {
        EmptyStateView(
            icon: "magnifyingglass",
            title: "No Results Found",
            message: "Try a different color name or clear the search filter.",
            actionTitle: nil,
            action: nil
        )
    }
}

