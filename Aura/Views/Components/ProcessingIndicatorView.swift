//
//  ProcessingIndicatorView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

/// Enhanced processing indicator with step-by-step feedback
struct ProcessingIndicatorView: View {
    
    let currentStep: ProcessingStep
    let progress: Double // 0.0 to 1.0
    @State private var isAnimating = false
    
    enum ProcessingStep: Int, CaseIterable {
        case analyzing = 0
        case detecting = 1
        case calculating = 2
        case finalizing = 3
        
        var title: String {
            switch self {
            case .analyzing:
                return NSLocalizedString("processing.analyzing", value: "Analyzing colors...", comment: "")
            case .detecting:
                return NSLocalizedString("processing.detecting", value: "Detecting aura...", comment: "")
            case .calculating:
                return NSLocalizedString("processing.calculating", value: "Calculating results...", comment: "")
            case .finalizing:
                return NSLocalizedString("processing.finalizing", value: "Almost done...", comment: "")
            }
        }
        
        var icon: String {
            switch self {
            case .analyzing: return "paintpalette.fill"
            case .detecting: return "sparkles"
            case .calculating: return "chart.bar.fill"
            case .finalizing: return "checkmark.circle.fill"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(Color.auraAccent.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                Image(systemName: currentStep.icon)
                    .font(.system(size: 50))
                    .foregroundColor(.auraAccent)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .opacity(isAnimating ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        isAnimating = true
                    }
            }
            
            // Step title
            Text(currentStep.title)
                .font(.title3.bold())
                .foregroundColor(.auraText)
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.auraSurface)
                        .frame(height: 8)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color.auraAccent, Color.auraAccent.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 8)
            .padding(.horizontal, LayoutConstants.largePadding)
            
            // Step indicators
            HStack(spacing: LayoutConstants.smallPadding) {
                ForEach(ProcessingStep.allCases, id: \.rawValue) { step in
                    Circle()
                        .fill(step.rawValue <= currentStep.rawValue ? Color.auraAccent : Color.auraSurface)
                        .frame(width: 8, height: 8)
                        .animation(.spring(), value: currentStep)
                }
            }
        }
        .padding(LayoutConstants.largePadding)
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
        .padding(.horizontal, LayoutConstants.padding)
    }
}

// MARK: - Preview

struct ProcessingIndicatorView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            ProcessingIndicatorView(
                currentStep: .detecting,
                progress: 0.6
            )
        }
    }
}

