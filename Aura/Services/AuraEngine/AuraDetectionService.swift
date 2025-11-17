//
//  AuraDetectionService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import UIKit
import Vision

/// Protocol defining aura detection capabilities
protocol AuraDetectionServiceProtocol {
    func detectAura(from image: UIImage, completion: @escaping (Result<AuraResult, AuraDetectionError>) -> Void)
    func detectFace(in image: UIImage, completion: @escaping (Result<VNFaceObservation, AuraDetectionError>) -> Void)
}

/// Errors that can occur during aura detection
enum AuraDetectionError: LocalizedError {
    case noFaceDetected
    case imageTooSmall
    case processingFailed
    case invalidImage
    case noAuraColorFound
    
    var errorDescription: String? {
        switch self {
        case .noFaceDetected:
            return "No face detected in the image"
        case .imageTooSmall:
            return "Image resolution is too small for accurate detection"
        case .processingFailed:
            return "Failed to process the image"
        case .invalidImage:
            return "Invalid image format"
        case .noAuraColorFound:
            return "Could not determine aura colors"
        }
    }
}

/// Main service for detecting aura colors from images
class AuraDetectionService: AuraDetectionServiceProtocol {
    
    private let colorAnalyzer: ColorAnalyzer
    private let minImageSize: CGFloat = 400.0
    private let auraExpansionFactor: CGFloat = 1.5 // Expand face region by 50%
    
    init(colorAnalyzer: ColorAnalyzer = ColorAnalyzer()) {
        self.colorAnalyzer = colorAnalyzer
    }
    
    // MARK: - Face Detection
    
    func detectFace(in image: UIImage, completion: @escaping (Result<VNFaceObservation, AuraDetectionError>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(.invalidImage))
            return
        }
        
        // Check minimum image size
        if image.size.width < minImageSize || image.size.height < minImageSize {
            completion(.failure(.imageTooSmall))
            return
        }
        
        let request = VNDetectFaceRectanglesRequest { request, error in
            if let error = error {
                print("Face detection error: \(error.localizedDescription)")
                completion(.failure(.processingFailed))
                return
            }
            
            guard let observations = request.results as? [VNFaceObservation],
                  let face = observations.first else {
                completion(.failure(.noFaceDetected))
                return
            }
            
            completion(.success(face))
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                completion(.failure(.processingFailed))
            }
        }
    }
    
    // MARK: - Aura Detection
    
    func detectAura(from image: UIImage, completion: @escaping (Result<AuraResult, AuraDetectionError>) -> Void) {
        // Step 1: Detect face
        detectFace(in: image) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let faceObservation):
                // Step 2: Extract aura region
                self.extractAuraRegion(from: image, faceObservation: faceObservation) { auraImage in
                    guard let auraImage = auraImage else {
                        completion(.failure(.processingFailed))
                        return
                    }
                    
                    // Step 3: Analyze colors
                    self.analyzeAuraColors(from: auraImage) { auraResult in
                        if let auraResult = auraResult {
                            completion(.success(auraResult))
                        } else {
                            completion(.failure(.noAuraColorFound))
                        }
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func extractAuraRegion(from image: UIImage, faceObservation: VNFaceObservation, completion: @escaping (UIImage?) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(nil)
            return
        }
        
        let imageSize = CGSize(width: cgImage.width, height: cgImage.height)
        
        // Convert Vision coordinates (0,0 at bottom-left) to UIKit coordinates (0,0 at top-left)
        let boundingBox = faceObservation.boundingBox
        let x = boundingBox.origin.x * imageSize.width
        let y = (1 - boundingBox.origin.y - boundingBox.height) * imageSize.height
        let width = boundingBox.size.width * imageSize.width
        let height = boundingBox.size.height * imageSize.height
        
        // Expand the region for aura analysis
        let expandedWidth = width * auraExpansionFactor
        let expandedHeight = height * auraExpansionFactor
        let expandedX = max(0, x - (expandedWidth - width) / 2)
        let expandedY = max(0, y - (expandedHeight - height) / 2)
        
        let auraRect = CGRect(
            x: expandedX,
            y: expandedY,
            width: min(expandedWidth, imageSize.width - expandedX),
            height: min(expandedHeight, imageSize.height - expandedY)
        )
        
        // Crop the image
        if let croppedCGImage = cgImage.cropping(to: auraRect) {
            let croppedImage = UIImage(cgImage: croppedCGImage)
            completion(croppedImage)
        } else {
            completion(nil)
        }
    }
    
    private func analyzeAuraColors(from image: UIImage, completion: @escaping (AuraResult?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }
            
            // Use ColorAnalyzer to extract dominant colors
            let dominantColors = self.colorAnalyzer.extractDominantColors(from: image, count: 3)
            
            guard !dominantColors.isEmpty else {
                completion(nil)
                return
            }
            
            // Map colors to aura colors
            let auraColors = dominantColors.compactMap { color -> (AuraColor, Double)? in
                if let auraColor = self.colorAnalyzer.mapToAuraColor(color) {
                    return (auraColor, 0.0) // Percentage will be calculated
                }
                return nil
            }
            
            guard !auraColors.isEmpty else {
                completion(nil)
                return
            }
            
            // Calculate percentages
            let total = Double(auraColors.count)
            var percentages: [Double] = []
            for i in 0..<auraColors.count {
                let percentage = (total - Double(i)) / total * 100.0
                percentages.append(percentage)
            }
            
            // Normalize percentages
            let sum = percentages.reduce(0, +)
            percentages = percentages.map { ($0 / sum) * 100.0 }
            
            // Get current country code
            let countryCode = Locale.current.regionCode ?? "US"
            
            // Create result
            let result = AuraResult(
                primaryColor: auraColors[0].0,
                secondaryColor: auraColors.count > 1 ? auraColors[1].0 : nil,
                tertiaryColor: auraColors.count > 2 ? auraColors[2].0 : nil,
                dominancePercentages: percentages,
                countryCode: countryCode,
                imageData: image.jpegData(compressionQuality: 0.7)
            )
            
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

