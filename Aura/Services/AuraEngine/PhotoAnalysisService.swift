//
//  PhotoAnalysisService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UIKit

/// Service for analyzing entire photo without face detection (outfit/environment analysis)
class PhotoAnalysisService {
    
    private let colorAnalyzer: ColorAnalyzer
    
    init(colorAnalyzer: ColorAnalyzer = ColorAnalyzer()) {
        self.colorAnalyzer = colorAnalyzer
    }
    
    // MARK: - Analyze Full Photo
    
    func analyzePhoto(_ image: UIImage, completion: @escaping (AuraResult?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            // Extract dominant colors from entire photo (no face detection)
            let dominantColors = self.colorAnalyzer.extractDominantColors(from: image, count: 3)
            
            guard !dominantColors.isEmpty else {
                completion(nil)
                return
            }
            
            // Map colors to aura colors
            let auraColors = dominantColors.compactMap { color -> AuraColor? in
                self.colorAnalyzer.mapToAuraColor(color)
            }
            
            guard !auraColors.isEmpty else {
                completion(nil)
                return
            }
            
            // Remove duplicates (keep first occurrence)
            var uniqueAuraColors: [AuraColor] = []
            for color in auraColors {
                if !uniqueAuraColors.contains(where: { $0.id == color.id }) {
                    uniqueAuraColors.append(color)
                }
            }
            
            // Calculate percentages based on position (simple heuristic)
            var percentages: [Double] = []
            let total = Double(uniqueAuraColors.count)
            for i in 0..<uniqueAuraColors.count {
                let percentage = ((total - Double(i)) / total) * 100.0
                percentages.append(percentage)
            }
            
            // Normalize
            let sum = percentages.reduce(0, +)
            percentages = percentages.map { ($0 / sum) * 100.0 }
            
            // Create result
            let result = AuraResult(
                primaryColor: uniqueAuraColors[0],
                secondaryColor: uniqueAuraColors.count > 1 ? uniqueAuraColors[1] : nil,
                tertiaryColor: uniqueAuraColors.count > 2 ? uniqueAuraColors[2] : nil,
                dominancePercentages: percentages,
                countryCode: Locale.current.regionCode ?? "US",
                imageData: image.jpegData(compressionQuality: 0.7)
            )
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

