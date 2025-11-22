//
//  ShareCardGenerator.swift
//  Aura
//
//  Created by Aura Team
//

import UIKit
import SwiftUI

/// Generator for shareable aura result cards
@MainActor
class ShareCardGenerator {
    
    static let shared = ShareCardGenerator()
    
    private init() {}
    
    /// Generate a shareable image from aura result
    func generateCard(for result: AuraResult) -> UIImage? {
        let size = CGSize(width: 1080, height: 1920)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background gradient
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = [
                UIColor(Color.auraBackground).cgColor,
                UIColor(Color.auraSurface).cgColor
            ]
            gradientLayer.locations = [0.0, 1.0]
            gradientLayer.frame = CGRect(origin: .zero, size: size)
            gradientLayer.render(in: context.cgContext)
            
            // Title
            let titleText = "My Aura"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleText.size(withAttributes: titleAttributes)
            titleText.draw(
                at: CGPoint(x: (size.width - titleSize.width) / 2, y: 150),
                withAttributes: titleAttributes
            )
            
            // Primary color circle
            let circleDiameter: CGFloat = 400
            let circleRect = CGRect(
                x: (size.width - circleDiameter) / 2,
                y: 400,
                width: circleDiameter,
                height: circleDiameter
            )
            
            // Gradient for primary color
            context.cgContext.saveGState()
            context.cgContext.addEllipse(in: circleRect)
            context.cgContext.clip()
            
            let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(result.primaryColor.color).cgColor,
                    UIColor(result.primaryColor.color.darker(by: 0.2)).cgColor
                ] as CFArray,
                locations: [0.0, 1.0]
            )!
            
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: circleRect.midX, y: circleRect.midY),
                startRadius: 0,
                endCenter: CGPoint(x: circleRect.midX, y: circleRect.midY),
                endRadius: circleDiameter / 2,
                options: []
            )
            context.cgContext.restoreGState()
            
            // Secondary ring
            if let secondaryColor = result.secondaryColor {
                let ringRect = circleRect.insetBy(dx: -40, dy: -40)
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: ringRect.midX, y: ringRect.midY),
                    radius: ringRect.width / 2,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: true
                )
                path.lineWidth = 30
                UIColor(secondaryColor.color).setStroke()
                path.stroke()
            }
            
            // Tertiary ring
            if let tertiaryColor = result.tertiaryColor {
                let ringRect = circleRect.insetBy(dx: -90, dy: -90)
                let path = UIBezierPath(
                    arcCenter: CGPoint(x: ringRect.midX, y: ringRect.midY),
                    radius: ringRect.width / 2,
                    startAngle: 0,
                    endAngle: .pi * 2,
                    clockwise: true
                )
                path.lineWidth = 20
                UIColor(tertiaryColor.color).setStroke()
                path.stroke()
            }
            
            // Primary color name
            let colorName = result.primaryColor.name
            let colorNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 64, weight: .semibold),
                .foregroundColor: UIColor.white
            ]
            let colorNameSize = colorName.size(withAttributes: colorNameAttributes)
            colorName.draw(
                at: CGPoint(x: (size.width - colorNameSize.width) / 2, y: 950),
                withAttributes: colorNameAttributes
            )
            
            // Percentage
            if !result.dominancePercentages.isEmpty {
                let percentageText = String(format: "%.0f%%", result.dominancePercentages[0])
                let percentageAttributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 48, weight: .regular),
                    .foregroundColor: UIColor.lightGray
                ]
                let percentageSize = percentageText.size(withAttributes: percentageAttributes)
                percentageText.draw(
                    at: CGPoint(x: (size.width - percentageSize.width) / 2, y: 1050),
                    withAttributes: percentageAttributes
                )
            }
            
            // Secondary colors
            var yOffset: CGFloat = 1180
            if let secondaryColor = result.secondaryColor {
                let text = "with \(secondaryColor.name)"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 36, weight: .regular),
                    .foregroundColor: UIColor(secondaryColor.color)
                ]
                let textSize = text.size(withAttributes: attributes)
                text.draw(
                    at: CGPoint(x: (size.width - textSize.width) / 2, y: yOffset),
                    withAttributes: attributes
                )
                yOffset += 60
            }
            
            if let tertiaryColor = result.tertiaryColor {
                let text = "and \(tertiaryColor.name)"
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: 36, weight: .regular),
                    .foregroundColor: UIColor(tertiaryColor.color)
                ]
                let textSize = text.size(withAttributes: attributes)
                text.draw(
                    at: CGPoint(x: (size.width - textSize.width) / 2, y: yOffset),
                    withAttributes: attributes
                )
            }
            
            // App name and disclaimer
            let appName = AppConstants.appName
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .light),
                .foregroundColor: UIColor.lightGray
            ]
            let appNameSize = appName.size(withAttributes: appNameAttributes)
            appName.draw(
                at: CGPoint(x: (size.width - appNameSize.width) / 2, y: size.height - 250),
                withAttributes: appNameAttributes
            )
            
            let disclaimer = "For entertainment purposes only"
            let disclaimerAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .light),
                .foregroundColor: UIColor.darkGray
            ]
            let disclaimerSize = disclaimer.size(withAttributes: disclaimerAttributes)
            disclaimer.draw(
                at: CGPoint(x: (size.width - disclaimerSize.width) / 2, y: size.height - 150),
                withAttributes: disclaimerAttributes
            )
        }
    }
    
    /// Generate a simple card with just colors (faster)
    func generateSimpleCard(for result: AuraResult) -> UIImage? {
        let size = CGSize(width: 600, height: 800)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 2.0
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background
            UIColor(Color.auraBackground).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Circle
            let circleDiameter: CGFloat = 300
            let circleRect = CGRect(
                x: (size.width - circleDiameter) / 2,
                y: 150,
                width: circleDiameter,
                height: circleDiameter
            )
            
            UIColor(result.primaryColor.color).setFill()
            context.cgContext.fillEllipse(in: circleRect)
            
            // Text
            let text = result.primaryColor.name
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let textSize = text.size(withAttributes: attributes)
            text.draw(
                at: CGPoint(x: (size.width - textSize.width) / 2, y: 500),
                withAttributes: attributes
            )
        }
    }
}

