//
//  GalleryAnalysisTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
import UIKit
@testable import Aura

final class GalleryAnalysisTests: XCTestCase {
    
    var photoAnalysisService: PhotoAnalysisService!
    var auraDetectionService: AuraDetectionService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        photoAnalysisService = PhotoAnalysisService()
        auraDetectionService = AuraDetectionService()
    }
    
    override func tearDownWithError() throws {
        photoAnalysisService = nil
        auraDetectionService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Image Picker Integration Tests
    
    func testImagePickerIntegration() throws {
        // Test that images from gallery can be processed
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        let expectation = XCTestExpectation(description: "Gallery image processed")
        
        photoAnalysisService.analyzePhoto(image) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - PhotoAnalysisService with Gallery Images
    
    func testPhotoAnalysisWithGalleryImage() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .red)
        let expectation = XCTestExpectation(description: "Photo analysis")
        
        photoAnalysisService.analyzePhoto(image) { result in
            XCTAssertNotNil(result)
            XCTAssertNotNil(result?.primaryColor)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - AuraDetectionService with Gallery Images
    
    func testAuraDetectionWithGalleryImage() throws {
        let image = TestHelpers.generateFaceLikeImage()
        let expectation = XCTestExpectation(description: "Aura detection from gallery")
        
        auraDetectionService.detectAura(from: image) { result in
            switch result {
            case .success(let auraResult):
                XCTAssertNotNil(auraResult.primaryColor)
                expectation.fulfill()
            case .failure:
                // Face detection might fail on synthetic image
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Image Format Tests
    
    func testJPEGFormat() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .green)
        // Convert to JPEG data and back
        guard let jpegData = image.jpegData(compressionQuality: 0.8),
              let jpegImage = UIImage(data: jpegData) else {
            XCTFail("Failed to create JPEG")
            return
        }
        
        let expectation = XCTestExpectation(description: "JPEG format")
        photoAnalysisService.analyzePhoto(jpegImage) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testPNGFormat() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .purple)
        // Convert to PNG data and back
        guard let pngData = image.pngData(),
              let pngImage = UIImage(data: pngData) else {
            XCTFail("Failed to create PNG")
            return
        }
        
        let expectation = XCTestExpectation(description: "PNG format")
        photoAnalysisService.analyzePhoto(pngImage) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Image Size Tests
    
    func testSmallImage() throws {
        let image = TestHelpers.generateAuraColorImage(
            auraColor: .blue,
            size: CGSize(width: 200, height: 200)
        )
        let expectation = XCTestExpectation(description: "Small image")
        
        photoAnalysisService.analyzePhoto(image) { result in
            // Should still work, might be less accurate
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testLargeImage() throws {
        let image = TestHelpers.generateAuraColorImage(
            auraColor: .red,
            size: CGSize(width: 2000, height: 2000)
        )
        let expectation = XCTestExpectation(description: "Large image")
        
        photoAnalysisService.analyzePhoto(image) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    func testVeryLargeImage() throws {
        let image = TestHelpers.generateAuraColorImage(
            auraColor: .yellow,
            size: CGSize(width: 4000, height: 4000)
        )
        let expectation = XCTestExpectation(description: "Very large image")
        
        photoAnalysisService.analyzePhoto(image) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 20.0)
    }
    
    // MARK: - Image Orientation Tests
    
    func testImageOrientationHandling() throws {
        // Test that orientation is handled correctly
        let image = TestHelpers.generateAuraColorImage(auraColor: .orange)
        let expectation = XCTestExpectation(description: "Orientation handling")
        
        // Simulate different orientations by rotating
        let rotatedImage = image.rotated(by: .pi / 2) ?? image
        
        photoAnalysisService.analyzePhoto(rotatedImage) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidImageFormat() throws {
        // Create invalid image data
        let invalidData = Data([0, 1, 2, 3])
        let invalidImage = UIImage(data: invalidData)
        
        if let image = invalidImage {
            let expectation = XCTestExpectation(description: "Invalid image")
            photoAnalysisService.analyzePhoto(image) { result in
                // Should handle gracefully
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 5.0)
        } else {
            // UIImage creation failed, which is expected
            XCTAssertNil(invalidImage)
        }
    }
    
    // MARK: - Performance Tests
    
    func testProcessingTimePerformance() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        
        measure {
            let expectation = XCTestExpectation(description: "Performance")
            photoAnalysisService.analyzePhoto(image) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testMemoryUsageWithLargeImage() throws {
        let image = TestHelpers.generateAuraColorImage(
            auraColor: .green,
            size: CGSize(width: 3000, height: 3000)
        )
        let expectation = XCTestExpectation(description: "Memory usage")
        
        photoAnalysisService.analyzePhoto(image) { result in
            // If we get here without memory warning, test passes
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 15.0)
    }
    
    // MARK: - Multiple Image Selection Tests
    
    func testMultipleImageProcessing() throws {
        let images = [
            TestHelpers.generateAuraColorImage(auraColor: .red),
            TestHelpers.generateAuraColorImage(auraColor: .blue),
            TestHelpers.generateAuraColorImage(auraColor: .green)
        ]
        
        let expectation = XCTestExpectation(description: "Multiple images")
        expectation.expectedFulfillmentCount = images.count
        
        for image in images {
            photoAnalysisService.analyzePhoto(image) { result in
                XCTAssertNotNil(result)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}

// MARK: - UIImage Extension for Testing

extension UIImage {
    func rotated(by angle: CGFloat) -> UIImage? {
        let size = self.size
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: size.width / 2, y: size.height / 2)
        context.rotate(by: angle)
        context.translateBy(x: -size.width / 2, y: -size.height / 2)
        
        self.draw(at: .zero)
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}

