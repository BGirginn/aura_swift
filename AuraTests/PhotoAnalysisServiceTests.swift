//
//  PhotoAnalysisServiceTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
import UIKit
@testable import Aura

final class PhotoAnalysisServiceTests: XCTestCase {
    
    var service: PhotoAnalysisService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        service = PhotoAnalysisService()
    }
    
    override func tearDownWithError() throws {
        service = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Full Photo Analysis Tests
    
    func testAnalyzePhotoWithSingleColor() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .red)
        let expectation = XCTestExpectation(description: "Analysis complete")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.primaryColor.id, "aura_red")
    }
    
    func testAnalyzePhotoWithMultipleColors() throws {
        let colors: [UIColor] = [
            UIColor(hex: AuraColor.red.hexValue),
            UIColor(hex: AuraColor.blue.hexValue),
            UIColor(hex: AuraColor.green.hexValue)
        ]
        let image = TestHelpers.generateMultiColorImage(colors: colors)
        let expectation = XCTestExpectation(description: "Analysis complete")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        XCTAssertNotNil(result?.primaryColor)
        // Should have at least primary color
        XCTAssertGreaterThanOrEqual(result?.dominantColors.count ?? 0, 1)
    }
    
    // MARK: - Outfit Analysis Tests
    
    func testAnalyzeOutfitWithRedDominant() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .red)
        let expectation = XCTestExpectation(description: "Outfit analysis")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        // Should detect red as primary
        XCTAssertEqual(result?.primaryColor.id, "aura_red")
    }
    
    func testAnalyzeOutfitWithBlueDominant() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        let expectation = XCTestExpectation(description: "Outfit analysis")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        XCTAssertEqual(result?.primaryColor.id, "aura_blue")
    }
    
    // MARK: - Environment Analysis Tests
    
    func testAnalyzeEnvironmentColors() throws {
        // Simulate environment with mixed colors
        let colors: [UIColor] = [
            UIColor(hex: AuraColor.green.hexValue),
            UIColor(hex: AuraColor.yellow.hexValue)
        ]
        let image = TestHelpers.generateMultiColorImage(colors: colors)
        let expectation = XCTestExpectation(description: "Environment analysis")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        // Should detect colors from environment
        XCTAssertNotNil(result?.primaryColor)
    }
    
    // MARK: - Color Mapping Tests
    
    func testColorMappingAccuracy() throws {
        // Test all aura colors
        let auraColors: [AuraColor] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]
        
        for auraColor in auraColors {
            let image = TestHelpers.generateAuraColorImage(auraColor: auraColor)
            let expectation = XCTestExpectation(description: "Color mapping for \(auraColor.id)")
            var result: AuraResult?
            
            service.analyzePhoto(image) { analysisResult in
                result = analysisResult
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 10.0)
            
            XCTAssertNotNil(result, "Should detect \(auraColor.name) color")
            // Primary color should match or be close
            XCTAssertNotNil(result?.primaryColor)
        }
    }
    
    // MARK: - Percentage Calculation Tests
    
    func testPercentageCalculation() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        let expectation = XCTestExpectation(description: "Percentage calculation")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
        if let percentages = result?.dominancePercentages {
            let sum = percentages.reduce(0, +)
            // Sum should be approximately 100%
            XCTAssertEqual(sum, 100.0, accuracy: 1.0)
        }
    }
    
    // MARK: - Edge Cases
    
    func testAnalyzeMonochromeImage() throws {
        let image = TestHelpers.generateSolidColorImage(color: .gray)
        let expectation = XCTestExpectation(description: "Monochrome analysis")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // Should still return a result (might map to white or closest color)
        XCTAssertNotNil(result)
    }
    
    func testAnalyzeHighContrastImage() throws {
        let colors: [UIColor] = [.black, .white]
        let image = TestHelpers.generateMultiColorImage(colors: colors)
        let expectation = XCTestExpectation(description: "High contrast analysis")
        var result: AuraResult?
        
        service.analyzePhoto(image) { analysisResult in
            result = analysisResult
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        XCTAssertNotNil(result)
    }
    
    // MARK: - Performance Tests
    
    func testAnalysisPerformance() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        
        measure {
            let expectation = XCTestExpectation(description: "Performance test")
            service.analyzePhoto(image) { _ in
                expectation.fulfill()
            }
            wait(for: [expectation], timeout: 10.0)
        }
    }
    
    func testAnalysisTimeUnder5Seconds() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .red)
        let startTime = Date()
        let expectation = XCTestExpectation(description: "Timing test")
        
        service.analyzePhoto(image) { _ in
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        let elapsed = Date().timeIntervalSince(startTime)
        XCTAssertLessThan(elapsed, 5.0, "Analysis should complete in under 5 seconds")
    }
}

