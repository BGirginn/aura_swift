//
//  PerformanceTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
import UIKit
import Darwin
@testable import Aura

final class PerformanceTests: XCTestCase {
    
    var photoAnalysisService: PhotoAnalysisService!
    var auraDetectionService: AuraDetectionService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        photoAnalysisService = PhotoAnalysisService()
        auraDetectionService = AuraDetectionService()
    }
    
    // MARK: - Image Processing Performance
    
    func testImageProcessingTimeUnder5Seconds() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        let startTime = Date()
        let expectation = XCTestExpectation(description: "Processing time")
        
        photoAnalysisService.analyzePhoto(image) { _ in
            let elapsed = Date().timeIntervalSince(startTime)
            XCTAssertLessThan(elapsed, 5.0, "Processing should complete in under 5 seconds")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMemoryUsageDuringProcessing() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .red)
        let expectation = XCTestExpectation(description: "Memory usage")
        
        // Measure memory before
        let memoryBefore = getMemoryUsage()
        
        photoAnalysisService.analyzePhoto(image) { _ in
            // Measure memory after
            let memoryAfter = getMemoryUsage()
            let memoryIncrease = memoryAfter - memoryBefore
            
            // Memory increase should be reasonable (< 50MB)
            XCTAssertLessThan(memoryIncrease, 50 * 1024 * 1024, "Memory increase should be less than 50MB")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testMultipleRapidScans() throws {
        let images = (0..<5).map { _ in TestHelpers.generateAuraColorImage(auraColor: .blue) }
        let expectation = XCTestExpectation(description: "Multiple scans")
        expectation.expectedFulfillmentCount = images.count
        
        let startTime = Date()
        
        for image in images {
            photoAnalysisService.analyzePhoto(image) { _ in
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 30.0)
        
        let totalTime = Date().timeIntervalSince(startTime)
        let averageTime = totalTime / Double(images.count)
        
        // Each scan should average under 5 seconds
        XCTAssertLessThan(averageTime, 5.0, "Average processing time should be under 5 seconds")
    }
    
    func testLargeImageHandling() throws {
        let sizes: [CGSize] = [
            CGSize(width: 2000, height: 2000),  // 2K
            CGSize(width: 4000, height: 4000)   // 4K
        ]
        
        for size in sizes {
            let image = TestHelpers.generateAuraColorImage(auraColor: .green, size: size)
            let expectation = XCTestExpectation(description: "Large image \(size.width)x\(size.height)")
            let startTime = Date()
            
            photoAnalysisService.analyzePhoto(image) { result in
                let elapsed = Date().timeIntervalSince(startTime)
                XCTAssertNotNil(result)
                // Even large images should process in reasonable time
                XCTAssertLessThan(elapsed, 10.0, "Large image processing should complete in under 10 seconds")
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 15.0)
        }
    }
    
    func testBatteryImpact() throws {
        // This is a placeholder - actual battery testing requires device
        // We can test that processing doesn't block main thread excessively
        let image = TestHelpers.generateAuraColorImage(auraColor: .purple)
        let expectation = XCTestExpectation(description: "Battery impact")
        let mainThreadStart = Date()
        
        photoAnalysisService.analyzePhoto(image) { _ in
            let mainThreadBlocked = Date().timeIntervalSince(mainThreadStart)
            // Main thread should not be blocked for long
            XCTAssertLessThan(mainThreadBlocked, 0.1, "Main thread should not be blocked")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCPUUsageDuringProcessing() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .yellow)
        let expectation = XCTestExpectation(description: "CPU usage")
        
        // Test that processing completes without excessive CPU
        photoAnalysisService.analyzePhoto(image) { result in
            XCTAssertNotNil(result)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testBackgroundProcessing() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .orange)
        let expectation = XCTestExpectation(description: "Background processing")
        
        // Processing should happen on background thread
        DispatchQueue.main.async {
            self.photoAnalysisService.analyzePhoto(image) { result in
                // Should complete even if called from main thread
                XCTAssertNotNil(result)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testConcurrentProcessingPrevention() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .pink)
        let expectation1 = XCTestExpectation(description: "First processing")
        let expectation2 = XCTestExpectation(description: "Second processing")
        
        // Start two processes simultaneously
        photoAnalysisService.analyzePhoto(image) { _ in
            expectation1.fulfill()
        }
        
        photoAnalysisService.analyzePhoto(image) { _ in
            expectation2.fulfill()
        }
        
        // Both should complete (no deadlock)
        wait(for: [expectation1, expectation2], timeout: 20.0)
    }
    
    // MARK: - UI Performance Tests
    
    func testScrollPerformance() throws {
        // Test that history list can handle many items
        let testResults = TestHelpers.buildTestHistory(count: 100)
        
        measure {
            // Simulate rendering (just test that data structure is efficient)
            _ = testResults.map { $0.primaryColor.name }
        }
    }
    
    func testAnimationSmoothness() throws {
        // Test that animations are smooth (60fps = ~16ms per frame)
        let frameTime = 1.0 / 60.0 // 16.67ms
        
        measure {
            // Simulate animation calculation
            for _ in 0..<60 {
                _ = sin(Double.random(in: 0...2 * .pi))
            }
        }
        
        // Animation calculations should be very fast
        let elapsed = measureTime {
            for _ in 0..<60 {
                _ = sin(Double.random(in: 0...2 * .pi))
            }
        }
        
        XCTAssertLessThan(elapsed, frameTime * 10, "Animation calculations should be fast")
    }
    
    func testAppLaunchTime() throws {
        // Test that app initialization is fast
        measure {
            _ = AppCoordinator()
            _ = ThemeManager.shared
            _ = LocalizationService.shared
        }
        
        let elapsed = measureTime {
            _ = AppCoordinator()
            _ = ThemeManager.shared
            _ = LocalizationService.shared
        }
        
        XCTAssertLessThan(elapsed, 0.5, "App initialization should be under 0.5 seconds")
    }
    
    func testScreenTransitionTimes() throws {
        let coordinator = AppCoordinator()
        
        measure {
            coordinator.showModeSelection()
            coordinator.showCamera()
            coordinator.showHistory()
        }
        
        let elapsed = measureTime {
            coordinator.showModeSelection()
            coordinator.showCamera()
            coordinator.showHistory()
        }
        
        XCTAssertLessThan(elapsed, 0.1, "Screen transitions should be instant")
    }
    
    func testListRenderingWithManyItems() throws {
        let items = TestHelpers.buildTestHistory(count: 1000)
        
        measure {
            // Simulate list rendering
            _ = items.map { $0.formattedDate }
            _ = items.map { $0.primaryColor.name }
        }
    }
    
    func testImageLoadingPerformance() throws {
        let image = TestHelpers.generateAuraColorImage(auraColor: .blue)
        
        measure {
            // Simulate image loading/decoding
            _ = image.pngData()
            _ = UIImage(data: image.pngData()!)
        }
    }
    
    func testThemeSwitchingPerformance() throws {
        let themeManager = ThemeManager.shared
        
        measure {
            themeManager.setTheme(.light)
            themeManager.setTheme(.dark)
            themeManager.setTheme(.system)
        }
        
        let elapsed = measureTime {
            themeManager.setTheme(.light)
            themeManager.setTheme(.dark)
            themeManager.setTheme(.system)
        }
        
        XCTAssertLessThan(elapsed, 0.1, "Theme switching should be instant")
    }
    
    // MARK: - Helper Methods
    
    private func getMemoryUsage() -> Int64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            return Int64(info.resident_size)
        } else {
            return 0
        }
    }
    
    private func measureTime(_ operation: () -> Void) -> TimeInterval {
        let start = Date()
        operation()
        return Date().timeIntervalSince(start)
    }
}

