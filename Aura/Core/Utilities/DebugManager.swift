//
//  DebugManager.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UIKit

/// Manager for debug and testing features
class DebugManager {
    
    static let shared = DebugManager()
    
    private let debugModeKey = "debug_mode_enabled"
    
    var isDebugMode: Bool {
        get {
            #if DEBUG
            return UserDefaults.standard.bool(forKey: debugModeKey)
            #else
            return false
            #endif
        }
        set {
            #if DEBUG
            UserDefaults.standard.set(newValue, forKey: debugModeKey)
            #endif
        }
    }
    
    private init() {}
    
    // MARK: - Sample Aura Results
    
    func generateSampleResult(colorType: AuraColor) -> AuraResult {
        // Create a sample result for testing
        let secondaryColors: [AuraColor] = AuraColor.allColors.filter { $0.id != colorType.id }
        let secondary = secondaryColors.randomElement()
        let tertiary = secondaryColors.filter { $0.id != secondary?.id }.randomElement()
        
        return AuraResult(
            timestamp: Date(),
            primaryColor: colorType,
            secondaryColor: secondary,
            tertiaryColor: tertiary,
            dominancePercentages: [60.0, 25.0, 15.0],
            countryCode: Locale.current.regionCode ?? "US",
            imageData: nil
        )
    }
    
    func generateRandomResult() -> AuraResult {
        let randomColor = AuraColor.allColors.randomElement() ?? .blue
        return generateSampleResult(colorType: randomColor)
    }
    
    // MARK: - Test Images
    
    func generateTestImage(color: UIColor) -> UIImage {
        let size = CGSize(width: 600, height: 800)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Background
            UIColor.black.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Colored circle (simulating aura)
            color.setFill()
            let circleRect = CGRect(
                x: (size.width - 400) / 2,
                y: (size.height - 400) / 2,
                width: 400,
                height: 400
            )
            context.cgContext.fillEllipse(in: circleRect)
            
            // Face silhouette (for Vision to detect)
            UIColor.white.setFill()
            let faceRect = CGRect(
                x: (size.width - 200) / 2,
                y: (size.height - 250) / 2,
                width: 200,
                height: 250
            )
            context.cgContext.fillEllipse(in: faceRect)
        }
    }
    
    // MARK: - Quick Test Buttons
    
    func getAllTestColors() -> [(name: String, color: AuraColor)] {
        return AuraColor.allColors.map { (name: $0.name, color: $0) }
    }
}

