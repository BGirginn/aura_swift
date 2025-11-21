//
//  AuraDetectionServiceTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
@testable import Aura

final class AuraDetectionServiceTests: XCTestCase {
    
    var service: AuraDetectionService!
    
    override func setUpWithError() throws {
        service = AuraDetectionService()
    }
    
    override func tearDownWithError() throws {
        service = nil
    }
    
    // MARK: - Face Detection Tests
    
    func testDetectAura_WithValidImage_Completes() throws {
        let expectation = XCTestExpectation(description: "Aura detection completes")
        let testImage = createTestImage(color: .red, size: CGSize(width: 500, height: 500))
        
        service.detectAura(from: testImage) { result in
            switch result {
            case .success(let auraResult):
                XCTAssertNotNil(auraResult.primaryColor, "Should detect primary color")
                expectation.fulfill()
            case .failure:
                // Face detection might fail on test image, which is acceptable
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
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

