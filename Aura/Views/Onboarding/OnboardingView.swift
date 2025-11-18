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
            title: "Discover Your Aura",
            description: "Reveal the colors of your energy field through advanced image analysis",
            icon: "sparkles"
        ),
        OnboardingPage(
            title: "Personalized Insights",
            description: "Get culturally adapted interpretations based on your location",
            icon: "globe.asia.australia"
        ),
        OnboardingPage(
            title: "Track Your Journey",
            description: "Monitor how your aura changes over time",
            icon: "chart.line.uptrend.xyaxis"
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
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Spacer()
            
            // Icon
            Image(systemName: page.icon)
                .font(.system(size: 100))
                .foregroundColor(.auraAccent)
                .padding(.bottom, LayoutConstants.padding)
            
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
            
            Spacer()
        }
    }
}

// MARK: - Preview

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(coordinator: AppCoordinator())
    }
}

