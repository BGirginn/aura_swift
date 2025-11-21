//
//  AuraRingsView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

/// Animated aura rings visualization
struct AuraRingsView: View {
    
    let auraColors: [AuraColor]
    let dominancePercentages: [Double]
    
    @State private var animationAmount: CGFloat = 1.0
    @State private var rotation: Double = 0
    
    var body: some View {
        ZStack {
            // Background glow
            ForEach(auraColors.indices, id: \.self) { index in
                let color = auraColors[index]
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.color.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150 + CGFloat(index * 30)
                        )
                    )
                    .frame(width: 300 + CGFloat(index * 60), height: 300 + CGFloat(index * 60))
                    .blur(radius: 20)
                    .scaleEffect(animationAmount)
            }
            
            // Main Rings
            ForEach(auraColors.indices, id: \.self) { index in
                let color = auraColors[index]
                let size: CGFloat = 200 + CGFloat(index * 60)
                
                Circle()
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [
                                color.color,
                                color.color.opacity(0.7),
                                color.color,
                                color.color.opacity(0.7),
                                color.color
                            ]),
                            center: .center,
                            angle: .degrees(rotation)
                        ),
                        lineWidth: AuraRingConstants.ringWidth
                    )
                    .frame(width: size, height: size)
                    .shadow(color: color.color.opacity(0.5), radius: 10)
                    .scaleEffect(animationAmount)
                    .rotationEffect(.degrees(rotation / Double(index + 1)))
            }
            
            // Center sparkle icon
            ZStack {
                Circle()
                    .fill(Color.auraBackground.opacity(0.8))
                    .frame(width: 80, height: 80)
                    .blur(radius: 2)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.5), radius: 10)
            }
            .scaleEffect(animationAmount)
        }
        .frame(height: 400)
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        // Pulse animation
        withAnimation(
            Animation.easeInOut(duration: 2.0)
                .repeatForever(autoreverses: true)
        ) {
            animationAmount = 1.05
        }
        
        // Rotation animation
        withAnimation(
            Animation.linear(duration: 20.0)
                .repeatForever(autoreverses: false)
        ) {
            rotation = 360
        }
    }
}

// MARK: - Preview

struct AuraRingsView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            AuraRingsView(
                auraColors: [.blue, .purple, .pink],
                dominancePercentages: [60, 25, 15]
            )
        }
    }
}

