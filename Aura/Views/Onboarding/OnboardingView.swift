//
//  OnboardingView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct OnboardingView: View {
    
    @StateObject private var coordinator: AppCoordinator
    @State private var currentPage = 0
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "See Your Hidden Colors",
            description: "Capture your aura with the camera or gallery using advanced on-device analysis. No uploads, no waiting.",
            icon: "sparkles",
            highlights: [
                "Face & full-photo scanning",
                "Real-time aura previews",
                "Privacy-first processing"
            ]
        ),
        OnboardingPage(
            title: "Interpretations That Feel Personal",
            description: "Choose your country to unlock culturally adapted meanings, aura stories, and personality insights.",
            icon: "globe.asia.australia",
            highlights: [
                "Localized descriptions (TR, US, DE, FR, UK)",
                "Story-style aura guidance",
                "Share-ready cards"
            ]
        ),
        OnboardingPage(
            title: "Track Energy Shifts Over Time",
            description: "Save results to history, favorite special scans, and revisit past auras whenever you want.",
            icon: "chart.line.uptrend.xyaxis",
            highlights: [
                "Timeline of every scan",
                "Personality quiz mode",
                "Debug/test tools for experiments"
            ]
        )
    ]
    
    init(coordinator: AppCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color.auraBackground, Color.auraSurface],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Pages
                TabView(selection: $currentPage) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .animation(.easeInOut(duration: 0.35), value: currentPage)
                
                // Continue Button
                Button(action: handleContinue) {
                    Text(currentPage == pages.count - 1 ? "Get Started" : "Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutConstants.buttonHeight)
                        .background(Color.auraAccent)
                        .cornerRadius(LayoutConstants.cornerRadius)
                }
                .padding(.horizontal, LayoutConstants.padding)
                .padding(.bottom, LayoutConstants.largePadding)
            }
        }
    }
    
    private func handleContinue() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            // Complete onboarding
            coordinator.hasCompletedOnboarding = true
        }
    }
}

// MARK: - Onboarding Page

struct OnboardingPage {
    let title: String
    let description: String
    let icon: String
    let highlights: [String]
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    @State private var iconScale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(.auraAccent)
                .scaleEffect(iconScale)
                .padding(.bottom, LayoutConstants.padding)
                .onAppear {
                    withAnimation(
                        Animation.easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                    ) {
                        iconScale = 1.1
                    }
                }
            
            // Title
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.auraText)
                .multilineTextAlignment(.center)
            
            // Description
            Text(page.description)
                .font(.system(size: 18))
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutConstants.largePadding)
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(page.highlights, id: \.self) { highlight in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "sparkle")
                            .foregroundColor(.auraAccent)
                        Text(highlight)
                            .font(.subheadline)
                            .foregroundColor(.auraTextSecondary)
                    }
                }
            }
            .padding(.horizontal, LayoutConstants.largePadding)
            
            Spacer()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(coordinator: AppCoordinator())
    }
}

