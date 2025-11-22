//
//  DataManagerTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
import CoreData
@testable import Aura

final class DataManagerTests: XCTestCase {
    
    var dataManager: DataManager!
    var testContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Create in-memory Core Data stack for testing
        let container = NSPersistentContainer(name: "AuraDataModel")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        description.shouldAddStoreAsynchronously = false
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Failed to load test store: \(error)")
            }
        }
        
        testContext = container.viewContext
        dataManager = DataManager.shared
    }
    
    override func tearDownWithError() throws {
        dataManager = nil
        testContext = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Save Tests
    
    func testSaveAuraResult() throws {
        let result = TestHelpers.createMockAuraResult(
            primaryColor: .blue,
            secondaryColor: .purple,
            countryCode: "US"
        )
        
        XCTAssertNoThrow(try dataManager.saveAuraResult(result))
        
        // Verify saved
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.primaryColor.id, result.primaryColor.id)
    }
    
    func testSaveMultipleResults() throws {
        let results = [
            TestHelpers.createMockAuraResult(primaryColor: .red, countryCode: "US"),
            TestHelpers.createMockAuraResult(primaryColor: .blue, countryCode: "TR"),
            TestHelpers.createMockAuraResult(primaryColor: .green, countryCode: "UK")
        ]
        
        for result in results {
            try dataManager.saveAuraResult(result)
        }
        
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 3)
    }
    
    // MARK: - Fetch Tests
    
    func testFetchAllHistory() throws {
        // Save multiple results
        for i in 0..<5 {
            let result = TestHelpers.createMockAuraResult(
                primaryColor: .blue,
                countryCode: i % 2 == 0 ? "US" : "TR"
            )
            try dataManager.saveAuraResult(result)
        }
        
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 5)
    }
    
    func testFetchFavorites() throws {
        // Save results
        let result1 = TestHelpers.createMockAuraResult(primaryColor: .red)
        let result2 = TestHelpers.createMockAuraResult(primaryColor: .blue)
        let result3 = TestHelpers.createMockAuraResult(primaryColor: .green)
        
        try dataManager.saveAuraResult(result1)
        try dataManager.saveAuraResult(result2)
        try dataManager.saveAuraResult(result3)
        
        // Mark first two as favorites
        try dataManager.toggleFavorite(result1)
        try dataManager.toggleFavorite(result2)
        
        let favorites = try dataManager.fetchFavorites()
        XCTAssertEqual(favorites.count, 2)
    }
    
    // MARK: - Delete Tests
    
    func testDeleteHistory() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .red)
        try dataManager.saveAuraResult(result)
        
        XCTAssertEqual(try dataManager.fetchAllHistory().count, 1)
        
        try dataManager.deleteHistory(result)
        
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 0)
    }
    
    func testDeleteAllHistory() throws {
        // Save multiple results
        for _ in 0..<5 {
            let result = TestHelpers.createMockAuraResult(primaryColor: .blue)
            try dataManager.saveAuraResult(result)
        }
        
        XCTAssertEqual(try dataManager.fetchAllHistory().count, 5)
        
        try dataManager.deleteAllHistory()
        
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 0)
    }
    
    // MARK: - Favorite Tests
    
    func testToggleFavorite() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .red)
        try dataManager.saveAuraResult(result)
        
        // Initially not favorite
        let favoritesBefore = try dataManager.fetchFavorites()
        XCTAssertFalse(favoritesBefore.contains(where: { $0.id == result.id }))
        
        // Toggle to favorite
        try dataManager.toggleFavorite(result)
        
        let favoritesAfter = try dataManager.fetchFavorites()
        XCTAssertTrue(favoritesAfter.contains(where: { $0.id == result.id }))
        
        // Toggle back to not favorite
        try dataManager.toggleFavorite(result)
        
        let favoritesFinal = try dataManager.fetchFavorites()
        XCTAssertFalse(favoritesFinal.contains(where: { $0.id == result.id }))
    }
    
    // MARK: - Persistence Tests
    
    func testDataPersistence() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .blue)
        try dataManager.saveAuraResult(result)
        
        // Save context
        dataManager.saveContext()
        
        // Fetch again (simulating app restart)
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 1)
        XCTAssertEqual(history.first?.primaryColor.id, result.primaryColor.id)
    }
    
    // MARK: - Edge Cases
    
    func testSaveResultWithAllColors() throws {
        let result = TestHelpers.createMockAuraResult(
            primaryColor: .red,
            secondaryColor: .orange,
            tertiaryColor: .yellow,
            countryCode: "US"
        )
        
        XCTAssertNoThrow(try dataManager.saveAuraResult(result))
        
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.first?.dominantColors.count, 3)
    }
    
    func testFetchEmptyHistory() throws {
        let history = try dataManager.fetchAllHistory()
        XCTAssertEqual(history.count, 0)
    }
    
    func testDeleteNonExistentResult() throws {
        let result = TestHelpers.createMockAuraResult(primaryColor: .red)
        
        // Should not throw when deleting non-existent result
        XCTAssertNoThrow(try dataManager.deleteHistory(result))
    }
}

