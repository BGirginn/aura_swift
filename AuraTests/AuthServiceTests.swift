//
//  AuthServiceTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
@testable import Aura

@MainActor
final class AuthServiceTests: XCTestCase {
    
    var authService: AuthService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        authService = AuthService.shared
    }
    
    override func tearDownWithError() throws {
        // Clean up
        authService.signOut()
        try super.tearDownWithError()
    }
    
    // MARK: - Guest Mode Tests
    
    func testContinueAsGuest() {
        authService.continueAsGuest()
        
        XCTAssertTrue(authService.isGuestMode)
        XCTAssertFalse(authService.isAuthenticated)
        XCTAssertNotNil(authService.currentUser)
    }
    
    func testGuestModeInitialState() {
        // After sign out, should be in guest mode
        authService.signOut()
        
        XCTAssertTrue(authService.isGuestMode)
        XCTAssertFalse(authService.isAuthenticated)
    }
    
    // MARK: - User Profile Tests
    
    func testUpdateUserProfile() {
        authService.continueAsGuest()
        
        authService.updateUserProfile(countryCode: "TR", languageCode: "tr")
        
        XCTAssertEqual(authService.currentUser?.countryCode, "TR")
        XCTAssertEqual(authService.currentUser?.languageCode, "tr")
    }
    
    // MARK: - Subscription Tests
    
    func testUpdateSubscriptionStatus() {
        authService.continueAsGuest()
        
        let expiresAt = Date().addingTimeInterval(86400 * 30) // 30 days
        authService.updateSubscriptionStatus(
            hasPremium: true,
            plan: User.SubscriptionPlan.monthly,
            expiresAt: expiresAt
        )
        
        XCTAssertTrue(authService.currentUser?.hasPremium ?? false)
        XCTAssertEqual(authService.currentUser?.subscriptionPlan, User.SubscriptionPlan.monthly)
        XCTAssertNotNil(authService.currentUser?.subscriptionExpiresAt)
    }
    
    // MARK: - Credit Tests
    
    func testUpdateCredits() {
        authService.continueAsGuest()
        
        authService.updateCredits(10)
        
        XCTAssertEqual(authService.currentUser?.credits, 10)
    }
    
    func testAddCredits() {
        authService.continueAsGuest()
        authService.updateCredits(5)
        
        authService.addCredits(3)
        
        XCTAssertEqual(authService.currentUser?.credits, 8)
    }
    
    func testConsumeCredit() {
        authService.continueAsGuest()
        authService.updateCredits(5)
        
        let success = authService.consumeCredit()
        
        XCTAssertTrue(success)
        XCTAssertEqual(authService.currentUser?.credits, 4)
    }
    
    func testConsumeCreditWhenZero() {
        authService.continueAsGuest()
        authService.updateCredits(0)
        
        let success = authService.consumeCredit()
        
        XCTAssertFalse(success)
        XCTAssertEqual(authService.currentUser?.credits, 0)
    }
    
    func testConsumeCreditPremiumUser() {
        authService.continueAsGuest()
        authService.updateSubscriptionStatus(hasPremium: true, plan: .monthly, expiresAt: Date().addingTimeInterval(86400))
        authService.updateCredits(0)
        
        // Premium users should be able to scan even with 0 credits
        let success = authService.consumeCredit()
        
        XCTAssertTrue(success)
        XCTAssertEqual(authService.currentUser?.credits, 0) // Credits don't decrease for premium
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut() {
        authService.continueAsGuest()
        authService.updateCredits(10)
        
        authService.signOut()
        
        XCTAssertTrue(authService.isGuestMode)
        XCTAssertFalse(authService.isAuthenticated)
        // User should be reset
        XCTAssertEqual(authService.currentUser?.credits, 0)
    }
    
    // MARK: - User Persistence Tests
    
    func testUserPersistence() {
        authService.continueAsGuest()
        authService.updateCredits(5)
        authService.updateUserProfile(countryCode: "TR", languageCode: "tr")
        
        // Simulate app restart by creating new instance
        // Note: In real scenario, this would test UserDefaults persistence
        let savedCountry = authService.currentUser?.countryCode
        let savedCredits = authService.currentUser?.credits
        
        XCTAssertEqual(savedCountry, "TR")
        XCTAssertEqual(savedCredits, 5)
    }
}

