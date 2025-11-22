//
//  TestHelpers.swift
//  AuraTests
//
//  Created by Aura Team
//

import Foundation
import UIKit
import Vision
import XCTest
@testable import Aura

/// Test utilities and helpers
class TestHelpers {
    
    // MARK: - Mock Image Generators
    
    /// Generate a test image with a solid color
    static func generateSolidColorImage(color: UIColor, size: CGSize = CGSize(width: 400, height: 400)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Generate a test image with multiple colors (for outfit testing)
    static func generateMultiColorImage(colors: [UIColor], size: CGSize = CGSize(width: 400, height: 400)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        let sectionWidth = size.width / CGFloat(colors.count)
        for (index, color) in colors.enumerated() {
            color.setFill()
            UIRectFill(CGRect(x: CGFloat(index) * sectionWidth, y: 0, width: sectionWidth, height: size.height))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Generate a test image with a face-like shape (for face detection testing)
    static func generateFaceLikeImage(size: CGSize = CGSize(width: 400, height: 400)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        defer { UIGraphicsEndImageContext() }
        
        let context = UIGraphicsGetCurrentContext()!
        
        // Background
        UIColor.white.setFill()
        context.fill(CGRect(origin: .zero, size: size))
        
        // Face circle
        let faceCenter = CGPoint(x: size.width / 2, y: size.height / 2)
        let faceRadius = min(size.width, size.height) * 0.3
        UIColor(red: 0.9, green: 0.8, blue: 0.7, alpha: 1.0).setFill()
        context.fillEllipse(in: CGRect(
            x: faceCenter.x - faceRadius,
            y: faceCenter.y - faceRadius,
            width: faceRadius * 2,
            height: faceRadius * 2
        ))
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    /// Generate a test image with specific aura color
    static func generateAuraColorImage(auraColor: AuraColor, size: CGSize = CGSize(width: 400, height: 400)) -> UIImage {
        return generateSolidColorImage(color: UIColor(hex: auraColor.hexValue), size: size)
    }
    
    // MARK: - Mock AuraResult Factory
    
    static func createMockAuraResult(
        primaryColor: AuraColor = .blue,
        secondaryColor: AuraColor? = .purple,
        tertiaryColor: AuraColor? = nil,
        countryCode: String = "US"
    ) -> AuraResult {
        let percentages: [Double]
        if let tertiary = tertiaryColor {
            percentages = [60.0, 30.0, 10.0]
        } else if let secondary = secondaryColor {
            percentages = [70.0, 30.0]
        } else {
            percentages = [100.0]
        }
        
        return AuraResult(
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            dominancePercentages: percentages,
            countryCode: countryCode
        )
    }
    
    // MARK: - Mock User Factory
    
    static func createMockUser(
        id: String = "test_user_123",
        countryCode: String = "US",
        languageCode: String = "en",
        hasPremium: Bool = false,
        credits: Int = 0
    ) -> User {
        return User(
            id: id,
            countryCode: countryCode,
            languageCode: languageCode,
            hasPremium: hasPremium,
            credits: credits
        )
    }
    
    // MARK: - Async Test Helpers
    
    /// Wait for async operation with timeout
    static func waitForAsync(
        timeout: TimeInterval = 5.0,
        description: String = "Async operation",
        operation: @escaping (@escaping () -> Void) -> Void
    ) {
        let expectation = XCTestExpectation(description: description)
        operation {
            expectation.fulfill()
        }
        XCTWaiter().wait(for: [expectation], timeout: timeout)
    }
    
    // MARK: - Performance Helpers
    
    /// Measure execution time
    static func measureTime(_ operation: () -> Void) -> TimeInterval {
        let start = Date()
        operation()
        return Date().timeIntervalSince(start)
    }
    
    /// Measure execution time for async operation
    static func measureAsyncTime(
        timeout: TimeInterval = 10.0,
        operation: @escaping (@escaping () -> Void) -> Void
    ) -> TimeInterval {
        let start = Date()
        let expectation = XCTestExpectation(description: "Async timing")
        operation {
            expectation.fulfill()
        }
        XCTWaiter().wait(for: [expectation], timeout: timeout)
        return Date().timeIntervalSince(start)
    }
    
    // MARK: - Test Data Builders
    
    static func buildTestHistory(count: Int) -> [AuraResult] {
        let colors: [AuraColor] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]
        var results: [AuraResult] = []
        
        for i in 0..<count {
            let primaryColor = colors[i % colors.count]
            let secondaryColor = i % 2 == 0 ? colors[(i + 1) % colors.count] : nil
            let result = createMockAuraResult(
                primaryColor: primaryColor,
                secondaryColor: secondaryColor,
                countryCode: i % 2 == 0 ? "US" : "TR"
            )
            results.append(result)
        }
        
        return results
    }
}

// MARK: - Mock Services

class MockAuraDetectionService: AuraDetectionServiceProtocol {
    var shouldSucceed = true
    var mockResult: AuraResult?
    var mockError: AuraDetectionError = .processingFailed
    
    func detectAura(from image: UIImage, completion: @escaping (Result<AuraResult, AuraDetectionError>) -> Void) {
        if shouldSucceed, let result = mockResult {
            completion(.success(result))
        } else {
            completion(.failure(mockError))
        }
    }
    
    func detectFace(in image: UIImage, completion: @escaping (Result<VNFaceObservation, AuraDetectionError>) -> Void) {
        if shouldSucceed {
            // For testing, we'll use actual Vision framework
            // In real tests, use actual face detection or mock the result differently
            let request = VNDetectFaceRectanglesRequest { request, error in
                if let observation = request.results?.first as? VNFaceObservation {
                    completion(.success(observation))
                } else {
                    completion(.failure(.noFaceDetected))
                }
            }
            let handler = VNImageRequestHandler(cgImage: image.cgImage!, options: [:])
            try? handler.perform([request])
        } else {
            completion(.failure(mockError))
        }
    }
}

class MockStorageService: StorageService {
    var savedResults: [AuraResult] = []
    var shouldFail = false
    
    override func saveAuraResult(_ result: AuraResult) throws {
        if shouldFail {
            throw NSError(domain: "TestError", code: 1)
        }
        savedResults.append(result)
    }
    
    override func fetchHistory(page: Int = 0, pageSize: Int = 20) throws -> [AuraResult] {
        if shouldFail {
            throw NSError(domain: "TestError", code: 1)
        }
        return savedResults
    }
}

// MARK: - Mock VNFaceObservation Helper

// Note: VNFaceObservation cannot be directly instantiated
// For testing, we'll use a mock or create actual face detection requests

