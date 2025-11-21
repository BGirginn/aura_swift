//
//  ColorAnalyzerTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
@testable import Aura

final class ColorAnalyzerTests: XCTestCase {
    
    var analyzer: ColorAnalyzer!
    
    override func setUpWithError() throws {
        analyzer = ColorAnalyzer()
    }
    
    override func tearDownWithError() throws {
        analyzer = nil
    }
    
    // MARK: - Color Mapping Tests (RGB to HSV tested indirectly through mapping)
    
    // MARK: - Aura Color Mapping Tests
    
    func testMapToAuraColor_Red() throws {
        let redColor = UIColor.red
        let auraColor = analyzer.mapToAuraColor(redColor)
        XCTAssertNotNil(auraColor, "Red color should map to an AuraColor")
        XCTAssertEqual(auraColor?.id, "aura_red", "Red color should map to aura_red")
    }
    
    func testMapToAuraColor_Blue() throws {
        let blueColor = UIColor.blue
        let auraColor = analyzer.mapToAuraColor(blueColor)
        XCTAssertNotNil(auraColor, "Blue color should map to an AuraColor")
        XCTAssertEqual(auraColor?.id, "aura_blue", "Blue color should map to aura_blue")
    }
    
    func testMapToAuraColor_Green() throws {
        let greenColor = UIColor.green
        let auraColor = analyzer.mapToAuraColor(greenColor)
        XCTAssertNotNil(auraColor, "Green color should map to an AuraColor")
        XCTAssertEqual(auraColor?.id, "aura_green", "Green color should map to aura_green")
    }
    
    // MARK: - Dominant Color Extraction Tests
    
    func testExtractDominantColors_ReturnsExpectedCount() throws {
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        let colors = analyzer.extractDominantColors(from: testImage, count: 3)
        XCTAssertEqual(colors.count, 3, "Should extract exactly 3 dominant colors")
    }
    
    func testExtractDominantColors_HandlesNilImage() throws {
        // This test verifies the method doesn't crash with invalid input
        let colors = analyzer.extractDominantColors(from: UIImage(), count: 3)
        XCTAssertTrue(colors.isEmpty || colors.count <= 3, "Should handle empty image gracefully")
    }
    
    // MARK: - Helper Methods
    
    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}

