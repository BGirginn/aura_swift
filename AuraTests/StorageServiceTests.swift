//
//  StorageServiceTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
@testable import Aura

final class StorageServiceTests: XCTestCase {
    
    var storageService: StorageService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        storageService = StorageService.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up test data
        try? storageService.deleteAllHistory()
        storageService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Local Storage Tests
    
    func testSaveAuraResult() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .blue)
        
        XCTAssertNoThrow(try storageService.saveAuraResult(result))
        
        let history = try storageService.fetchHistory()
        XCTAssertEqual(history.count, 1)
    }
    
    func testFetchHistory() throws {
        // Save multiple results
        for i in 0..<10 {
            let result = TestHelpers.createMockAuraResult(
                primaryColor: .blue,
                countryCode: i % 2 == 0 ? "US" : "TR"
            )
            try storageService.saveAuraResult(result)
        }
        
        let history = try storageService.fetchHistory()
        XCTAssertEqual(history.count, 10)
    }
    
    func testFetchFavorites() throws {
        let result1 = TestHelpers.createMockAuraResult(primaryColor: .red)
        let result2 = TestHelpers.createMockAuraResult(primaryColor: .blue)
        
        try storageService.saveAuraResult(result1)
        try storageService.saveAuraResult(result2)
        
        try storageService.toggleFavorite(result1)
        
        let favorites = try storageService.fetchFavorites()
        XCTAssertEqual(favorites.count, 1)
        XCTAssertEqual(favorites.first?.id, result1.id)
    }
    
    func testDeleteHistory() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .red)
        try storageService.saveAuraResult(result)
        
        try storageService.deleteHistory(result)
        
        let history = try storageService.fetchHistory()
        XCTAssertFalse(history.contains(where: { $0.id == result.id }))
    }
    
    func testDeleteAllHistory() throws {
        // Save multiple results
        for _ in 0..<5 {
            let result = TestHelpers.createMockAuraResult(primaryColor: .blue)
            try storageService.saveAuraResult(result)
        }
        
        try storageService.deleteAllHistory()
        
        let history = try storageService.fetchHistory()
        XCTAssertEqual(history.count, 0)
    }
    
    func testToggleFavorite() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .red)
        try storageService.saveAuraResult(result)
        
        // Toggle to favorite
        try storageService.toggleFavorite(result)
        
        var favorites = try storageService.fetchFavorites()
        XCTAssertTrue(favorites.contains(where: { $0.id == result.id }))
        
        // Toggle back
        try storageService.toggleFavorite(result)
        
        favorites = try storageService.fetchFavorites()
        XCTAssertFalse(favorites.contains(where: { $0.id == result.id }))
    }
    
    // MARK: - User Settings Tests
    
    func testSaveUserSettings() {
        storageService.saveUserSettings(
            countryCode: "TR",
            languageCode: "tr",
            savePhotos: true,
            analyticsEnabled: true
        )
        
        let savedCountry = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedCountryCode)
        let savedLanguage = UserDefaults.standard.string(forKey: UserDefaultsKeys.selectedLanguage)
        
        XCTAssertEqual(savedCountry, "TR")
        XCTAssertEqual(savedLanguage, "tr")
    }
    
    // MARK: - Cloud Sync Tests (Mock)
    
    func testCloudSyncEnabled() {
        // Cloud sync should be disabled by default (Firebase not configured)
        XCTAssertFalse(storageService.cloudSyncEnabled)
    }
    
    // MARK: - Performance Tests
    
    func testSavePerformance() throws {
        measure {
            for i in 0..<100 {
                let result = TestHelpers.createMockAuraResult(
                    primaryColor: .blue,
                    countryCode: "US"
                )
                try? storageService.saveAuraResult(result)
            }
        }
    }
    
    func testFetchPerformance() throws {
        // Pre-populate
        for _ in 0..<100 {
            let result = TestHelpers.createMockAuraResult(primaryColor: .blue)
            try storageService.saveAuraResult(result)
        }
        
        measure {
            _ = try? storageService.fetchHistory()
        }
    }
}

