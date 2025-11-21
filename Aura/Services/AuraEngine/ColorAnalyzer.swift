//
//  ColorAnalyzer.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UIKit
import CoreImage

/// Service for analyzing colors in images using HSV color space and k-means clustering
class ColorAnalyzer {
    
    private let downsampleSize: CGSize = CGSize(width: 100, height: 100)
    private let blurRadius: CGFloat = 5.0
    
    // MARK: - Public Methods
    
    /// Extract dominant colors from an image using k-means clustering
    func extractDominantColors(from image: UIImage, count: Int = 3) -> [UIColor] {
        // Downscale and blur the image for better performance
        guard let processedImage = preprocessImage(image) else {
            return []
        }
        
        // Extract pixel colors
        guard let pixelColors = extractPixelColors(from: processedImage) else {
            return []
        }
        
        // Perform k-means clustering
        let clusters = performKMeans(on: pixelColors, k: count)
        
        // Convert cluster centers to UIColor
        return clusters.map { UIColor(hue: $0.h, saturation: $0.s, brightness: $0.v, alpha: 1.0) }
    }
    
    /// Map a UIColor to the closest AuraColor
    func mapToAuraColor(_ color: UIColor) -> AuraColor? {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        
        // Convert to degrees
        let hueDegrees = hue * 360.0
        
        // Find matching aura color
        for auraColor in AuraColor.allColors {
            if auraColor.hueRange.contains(Double(hueDegrees)) &&
               Double(saturation) >= auraColor.saturationMin &&
               Double(brightness) >= auraColor.brightnessMin {
                return auraColor
            }
        }
        
        // If no match, return the closest by hue
        return findClosestAuraColorByHue(hueDegrees: Double(hueDegrees))
    }
    
    // MARK: - Private Methods
    
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        guard let cgImage = image.cgImage else { return nil }
        
        // Downscale
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: downsampleSize, format: format)
        
        let downsampledImage = renderer.image { context in
            UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: downsampleSize))
        }
        
        // Apply blur
        guard let inputImage = CIImage(image: downsampledImage) else { return downsampledImage }
        
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(blurRadius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter?.outputImage else { return downsampledImage }
        
        let context = CIContext()
        guard let cgImageBlurred = context.createCGImage(outputImage, from: inputImage.extent) else {
            return downsampledImage
        }
        
        return UIImage(cgImage: cgImageBlurred)
    }
    
    private func extractPixelColors(from image: UIImage) -> [HSVColor]? {
        guard let cgImage = image.cgImage else { return nil }
        
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        
        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var hsvColors: [HSVColor] = []
        
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let r = CGFloat(pixelData[offset]) / 255.0
                let g = CGFloat(pixelData[offset + 1]) / 255.0
                let b = CGFloat(pixelData[offset + 2]) / 255.0
                
                let hsv = rgbToHSV(r: r, g: g, b: b)
                
                // Filter out very dark or very light colors (noise)
                if hsv.v > 0.1 && hsv.v < 0.95 && hsv.s > 0.1 {
                    hsvColors.append(hsv)
                }
            }
        }
        
        return hsvColors
    }
    
    private func rgbToHSV(r: CGFloat, g: CGFloat, b: CGFloat) -> HSVColor {
        let max = Swift.max(r, g, b)
        let min = Swift.min(r, g, b)
        let delta = max - min
        
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        let value = max
        
        if delta != 0 {
            saturation = delta / max
            
            if r == max {
                hue = (g - b) / delta
            } else if g == max {
                hue = 2 + (b - r) / delta
            } else {
                hue = 4 + (r - g) / delta
            }
            
            hue *= 60
            if hue < 0 {
                hue += 360
            }
        }
        
        return HSVColor(h: hue / 360.0, s: saturation, v: value)
    }
    
    private func performKMeans(on colors: [HSVColor], k: Int, maxIterations: Int = 20) -> [HSVColor] {
        guard !colors.isEmpty, k > 0, k <= colors.count else { return [] }
        
        // Initialize centroids randomly
        var centroids = Array(colors.shuffled().prefix(k))
        
        for _ in 0..<maxIterations {
            // Assign colors to nearest centroid
            var clusters: [[HSVColor]] = Array(repeating: [], count: k)
            
            for color in colors {
                let nearestIndex = findNearestCentroid(for: color, in: centroids)
                clusters[nearestIndex].append(color)
            }
            
            // Update centroids
            var newCentroids: [HSVColor] = []
            for cluster in clusters {
                if cluster.isEmpty {
                    newCentroids.append(centroids[newCentroids.count])
                } else {
                    let avgH = cluster.map { $0.h }.reduce(0, +) / CGFloat(cluster.count)
                    let avgS = cluster.map { $0.s }.reduce(0, +) / CGFloat(cluster.count)
                    let avgV = cluster.map { $0.v }.reduce(0, +) / CGFloat(cluster.count)
                    newCentroids.append(HSVColor(h: avgH, s: avgS, v: avgV))
                }
            }
            
            // Check for convergence
            if centroids == newCentroids {
                break
            }
            
            centroids = newCentroids
        }
        
        return centroids
    }
    
    private func findNearestCentroid(for color: HSVColor, in centroids: [HSVColor]) -> Int {
        var minDistance = CGFloat.infinity
        var nearestIndex = 0
        
        for (index, centroid) in centroids.enumerated() {
            let distance = colorDistance(color, centroid)
            if distance < minDistance {
                minDistance = distance
                nearestIndex = index
            }
        }
        
        return nearestIndex
    }
    
    private func colorDistance(_ c1: HSVColor, _ c2: HSVColor) -> CGFloat {
        // Use Euclidean distance in HSV space
        let dh = min(abs(c1.h - c2.h), 1 - abs(c1.h - c2.h)) // Circular hue distance
        let ds = c1.s - c2.s
        let dv = c1.v - c2.v
        
        return sqrt(dh * dh + ds * ds + dv * dv)
    }
    
    private func findClosestAuraColorByHue(hueDegrees: Double) -> AuraColor? {
        var closestColor: AuraColor?
        var minDistance = Double.infinity
        
        for auraColor in AuraColor.allColors {
            let midHue = (auraColor.hueRange.lowerBound + auraColor.hueRange.upperBound) / 2
            let distance = abs(hueDegrees - midHue)
            
            if distance < minDistance {
                minDistance = distance
                closestColor = auraColor
            }
        }
        
        return closestColor
    }
}

// MARK: - Supporting Types

struct HSVColor: Equatable {
    let h: CGFloat // 0.0 to 1.0
    let s: CGFloat // 0.0 to 1.0
    let v: CGFloat // 0.0 to 1.0
}

