//
//  AuraColor.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import SwiftUI

/// Represents an aura color with its characteristics and localized descriptions
struct AuraColor: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let hueRange: ClosedRange<Double>
    let saturationMin: Double
    let brightnessMin: Double
    let hexValue: String
    
    // Localized descriptions will be loaded from JSON
    var localizedDescriptions: [String: LocalizedDescription]
    
    struct LocalizedDescription: Codable, Equatable {
        let countryCode: String
        let shortDescription: String
        let longDescription: String
        let traits: [String]
        let advice: String
    }
    
    // Computed property for SwiftUI Color
    var color: Color {
        Color(hex: hexValue)
    }
    
    // Custom coding keys for JSON compatibility
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case hueRange
        case saturationMin
        case brightnessMin
        case hexValue
        case localizedDescriptions
    }
    
    // Custom initializer
    init(id: String, 
         name: String, 
         hueRange: ClosedRange<Double>, 
         saturationMin: Double, 
         brightnessMin: Double, 
         hexValue: String,
         localizedDescriptions: [String: LocalizedDescription] = [:]) {
        self.id = id
        self.name = name
        self.hueRange = hueRange
        self.saturationMin = saturationMin
        self.brightnessMin = brightnessMin
        self.hexValue = hexValue
        self.localizedDescriptions = localizedDescriptions
    }
    
    // Custom Codable implementation to handle ClosedRange
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        
        let rangeArray = try container.decode([Double].self, forKey: .hueRange)
        guard rangeArray.count == 2 else {
            throw DecodingError.dataCorruptedError(forKey: .hueRange, in: container, debugDescription: "Hue range must have exactly 2 values")
        }
        hueRange = rangeArray[0]...rangeArray[1]
        
        saturationMin = try container.decode(Double.self, forKey: .saturationMin)
        brightnessMin = try container.decode(Double.self, forKey: .brightnessMin)
        hexValue = try container.decode(String.self, forKey: .hexValue)
        localizedDescriptions = try container.decode([String: LocalizedDescription].self, forKey: .localizedDescriptions)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode([hueRange.lowerBound, hueRange.upperBound], forKey: .hueRange)
        try container.encode(saturationMin, forKey: .saturationMin)
        try container.encode(brightnessMin, forKey: .brightnessMin)
        try container.encode(hexValue, forKey: .hexValue)
        try container.encode(localizedDescriptions, forKey: .localizedDescriptions)
    }
}

// MARK: - Predefined Aura Colors
extension AuraColor {
    static let red = AuraColor(
        id: "aura_red",
        name: "Red",
        hueRange: 0...20,
        saturationMin: 0.5,
        brightnessMin: 0.4,
        hexValue: "#FF0000"
    )
    
    static let orange = AuraColor(
        id: "aura_orange",
        name: "Orange",
        hueRange: 21...40,
        saturationMin: 0.5,
        brightnessMin: 0.4,
        hexValue: "#FF8800"
    )
    
    static let yellow = AuraColor(
        id: "aura_yellow",
        name: "Yellow",
        hueRange: 41...70,
        saturationMin: 0.4,
        brightnessMin: 0.5,
        hexValue: "#FFFF00"
    )
    
    static let green = AuraColor(
        id: "aura_green",
        name: "Green",
        hueRange: 71...150,
        saturationMin: 0.3,
        brightnessMin: 0.3,
        hexValue: "#00FF00"
    )
    
    static let blue = AuraColor(
        id: "aura_blue",
        name: "Blue",
        hueRange: 151...240,
        saturationMin: 0.3,
        brightnessMin: 0.3,
        hexValue: "#0088FF"
    )
    
    static let purple = AuraColor(
        id: "aura_purple",
        name: "Purple",
        hueRange: 241...290,
        saturationMin: 0.4,
        brightnessMin: 0.3,
        hexValue: "#8800FF"
    )
    
    static let pink = AuraColor(
        id: "aura_pink",
        name: "Pink",
        hueRange: 291...330,
        saturationMin: 0.4,
        brightnessMin: 0.5,
        hexValue: "#FF00FF"
    )
    
    static let white = AuraColor(
        id: "aura_white",
        name: "White",
        hueRange: 0...360,
        saturationMin: 0.0,
        brightnessMin: 0.8,
        hexValue: "#FFFFFF"
    )
    
    static let allColors: [AuraColor] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink, .white
    ]
}

