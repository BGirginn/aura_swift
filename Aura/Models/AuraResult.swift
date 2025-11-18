//
//  AuraResult.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UIKit

/// Represents the result of an aura detection scan
struct AuraResult: Identifiable, Codable, Equatable {
    let id: UUID
    let timestamp: Date
    let primaryColor: AuraColor
    let secondaryColor: AuraColor?
    let tertiaryColor: AuraColor?
    let dominancePercentages: [Double] // [primary%, secondary%, tertiary%]
    let countryCode: String
    let imageData: Data? // Optional: store the captured photo
    
    // Computed properties
    var dominantColors: [AuraColor] {
        var colors = [primaryColor]
        if let secondary = secondaryColor {
            colors.append(secondary)
        }
        if let tertiary = tertiaryColor {
            colors.append(tertiary)
        }
        return colors
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var image: UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
    
    // Custom initializer
    init(id: UUID = UUID(),
         timestamp: Date = Date(),
         primaryColor: AuraColor,
         secondaryColor: AuraColor? = nil,
         tertiaryColor: AuraColor? = nil,
         dominancePercentages: [Double] = [],
         countryCode: String,
         imageData: Data? = nil) {
        self.id = id
        self.timestamp = timestamp
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.tertiaryColor = tertiaryColor
        self.dominancePercentages = dominancePercentages
        self.countryCode = countryCode
        self.imageData = imageData
    }
}

// MARK: - Preview Helper
extension AuraResult {
    static var preview: AuraResult {
        AuraResult(
            primaryColor: .blue,
            secondaryColor: .purple,
            tertiaryColor: .pink,
            dominancePercentages: [60.0, 25.0, 15.0],
            countryCode: "TR"
        )
    }
    
    static var previewArray: [AuraResult] {
        [
            AuraResult(
                timestamp: Date().addingTimeInterval(-86400 * 1),
                primaryColor: .yellow,
                secondaryColor: .green,
                dominancePercentages: [70.0, 30.0],
                countryCode: "US"
            ),
            AuraResult(
                timestamp: Date().addingTimeInterval(-86400 * 3),
                primaryColor: .purple,
                secondaryColor: .blue,
                tertiaryColor: .pink,
                dominancePercentages: [50.0, 30.0, 20.0],
                countryCode: "TR"
            ),
            AuraResult(
                timestamp: Date().addingTimeInterval(-86400 * 7),
                primaryColor: .green,
                dominancePercentages: [100.0],
                countryCode: "UK"
            )
        ]
    }
}

