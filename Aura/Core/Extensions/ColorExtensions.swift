//
//  ColorExtensions.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import UIKit

// MARK: - Color Extension for Hex Support

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - UIColor Extension

extension UIColor {
    /// Initialize UIColor from hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
    
    /// Convert UIColor to hex string
    func toHex() -> String? {
        guard let components = cgColor.components, components.count >= 3 else {
            return nil
        }
        
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        return String(format: "#%02lX%02lX%02lX",
                     lroundf(r * 255),
                     lroundf(g * 255),
                     lroundf(b * 255))
    }
}

// MARK: - Gradient Helpers

extension Color {
    /// Create a gradient from an array of aura colors
    static func auraGradient(colors: [AuraColor]) -> LinearGradient {
        let swiftUIColors = colors.map { $0.color }
        return LinearGradient(
            gradient: Gradient(colors: swiftUIColors),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    /// Create a radial gradient for aura rings
    static func auraRadialGradient(colors: [AuraColor]) -> RadialGradient {
        let swiftUIColors = colors.map { $0.color }
        return RadialGradient(
            gradient: Gradient(colors: swiftUIColors),
            center: .center,
            startRadius: 50,
            endRadius: 200
        )
    }
}

// MARK: - Theme Colors

extension Color {
    // Dark theme colors (original)
    static let auraBackgroundDark = Color(hex: "#0A0A0F")
    static let auraSurfaceDark = Color(hex: "#1A1A2E")
    static let auraTextDark = Color(hex: "#FFFFFF")
    static let auraTextSecondaryDark = Color(hex: "#A0A0B0")
    
    // Light theme colors
    static let auraBackgroundLight = Color(hex: "#F5F5F7")
    static let auraSurfaceLight = Color(hex: "#FFFFFF")
    static let auraTextLight = Color(hex: "#000000")
    static let auraTextSecondaryLight = Color(hex: "#6E6E73")
    
    // Accent color (same for both themes)
    static let auraAccent = Color(hex: "#6C5CE7")
    
    // Adaptive theme colors
    static var auraBackground: Color {
        ThemeColor.background.color
    }
    
    static var auraSurface: Color {
        ThemeColor.surface.color
    }
    
    static var auraText: Color {
        ThemeColor.text.color
    }
    
    static var auraTextSecondary: Color {
        ThemeColor.textSecondary.color
    }
}

// MARK: - Theme Color Helper

struct ThemeColor {
    enum ColorType {
        case background
        case surface
        case text
        case textSecondary
    }
    
    let type: ColorType
    
    var color: Color {
        // Get current theme preference
        let themePreference = ThemeManager.shared.themePreference
        let isDark: Bool
        
        switch themePreference {
        case .light:
            isDark = false
        case .dark:
            isDark = true
        case .system:
            // Check system preference
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                isDark = windowScene.windows.first?.traitCollection.userInterfaceStyle == .dark
            } else {
                isDark = true // Default to dark
            }
        }
        
        switch (type, isDark) {
        case (.background, true):
            return .auraBackgroundDark
        case (.background, false):
            return .auraBackgroundLight
        case (.surface, true):
            return .auraSurfaceDark
        case (.surface, false):
            return .auraSurfaceLight
        case (.text, true):
            return .auraTextDark
        case (.text, false):
            return .auraTextLight
        case (.textSecondary, true):
            return .auraTextSecondaryDark
        case (.textSecondary, false):
            return .auraTextSecondaryLight
        }
    }
    
    static var background: ThemeColor {
        ThemeColor(type: .background)
    }
    
    static var surface: ThemeColor {
        ThemeColor(type: .surface)
    }
    
    static var text: ThemeColor {
        ThemeColor(type: .text)
    }
    
    static var textSecondary: ThemeColor {
        ThemeColor(type: .textSecondary)
    }
}

// MARK: - Color Manipulation

extension Color {
    /// Lighten the color by a percentage
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    /// Darken the color by a percentage
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.adjust(by: -abs(percentage))
    }
    
    private func adjust(by percentage: CGFloat) -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return Color(
            red: min(Double(red + percentage), 1.0),
            green: min(Double(green + percentage), 1.0),
            blue: min(Double(blue + percentage), 1.0),
            opacity: Double(alpha)
        )
    }
}

