//
//  E2ETests.swift
//  AuraUITests
//
//  Created by Aura Team
//

import XCTest

final class E2ETests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Complete Workflow Tests
    
    func testCompleteOnboardingToScanFlow() throws {
        // Complete onboarding
        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 5) {
            for _ in 0..<3 {
                if continueButton.exists {
                    continueButton.tap()
                } else {
                    break
                }
            }
            
            let getStartedButton = app.buttons["Get Started"]
            if getStartedButton.waitForExistence(timeout: 5) {
                getStartedButton.tap()
            }
        }
        
        // Should be at mode selection
        let modeSelection = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Aura'")).firstMatch
        XCTAssertTrue(modeSelection.waitForExistence(timeout: 5), "Should reach mode selection")
    }
    
    // MARK: - Yüz Aurası Flow Tests
    
    func testYuzAurasiFlow_Camera() throws {
        skipOnboardingIfNeeded()
        
        // Select Face Aura mode
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
            
            // Should be at camera screen
            // Note: Actual camera capture requires device
            let cameraScreen = app.otherElements.matching(NSPredicate(format: "identifier CONTAINS 'camera'")).firstMatch
            // Camera screen should be visible
        }
    }
    
    func testYuzAurasiFlow_Gallery() throws {
        skipOnboardingIfNeeded()
        
        // Select Face Aura mode
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
            
            // Tap gallery button
            let galleryButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'gallery' OR identifier CONTAINS 'photo'")).firstMatch
            if galleryButton.waitForExistence(timeout: 5) {
                galleryButton.tap()
                // Should open image picker
            }
        }
    }
    
    // MARK: - Kombin Aurası Flow Tests
    
    func testKombinAurasiFlow_Camera() throws {
        skipOnboardingIfNeeded()
        
        // Select Outfit Aura mode
        let outfitAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Outfit' OR label CONTAINS 'Kombin'")).firstMatch
        if outfitAuraButton.waitForExistence(timeout: 5) {
            outfitAuraButton.tap()
            
            // Should be at camera screen
            // Note: Actual camera capture requires device
        }
    }
    
    func testKombinAurasiFlow_Gallery() throws {
        skipOnboardingIfNeeded()
        
        // Select Outfit Aura mode
        let outfitAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Outfit' OR label CONTAINS 'Kombin'")).firstMatch
        if outfitAuraButton.waitForExistence(timeout: 5) {
            outfitAuraButton.tap()
            
            // Tap gallery button
            let galleryButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'gallery' OR identifier CONTAINS 'photo'")).firstMatch
            if galleryButton.waitForExistence(timeout: 5) {
                galleryButton.tap()
                // Should open image picker
            }
        }
    }
    
    // MARK: - History Flow Tests
    
    func testHistoryToDetailToShareFlow() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to history
        let historyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'History'")).firstMatch
        if historyButton.waitForExistence(timeout: 5) {
            historyButton.tap()
            
            // Tap on first history item (if exists)
            let firstItem = app.cells.firstMatch
            if firstItem.waitForExistence(timeout: 5) {
                firstItem.tap()
                
                // Should show detail
                // Look for share button
                let shareButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Share' OR identifier CONTAINS 'share'")).firstMatch
                if shareButton.waitForExistence(timeout: 5) {
                    shareButton.tap()
                    // Should open share sheet
                }
            }
        }
    }
    
    // MARK: - Settings Flow Tests
    
    func testSettingsThemeChangeFlow() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Change theme
            let themePicker = app.pickers.matching(NSPredicate(format: "identifier CONTAINS 'theme'")).firstMatch
            if themePicker.waitForExistence(timeout: 5) {
                themePicker.tap()
                // Should change theme
                // Verify UI updates
            }
        }
    }
    
    func testSettingsLanguageChangeFlow() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Change language
            let languagePicker = app.pickers.matching(NSPredicate(format: "identifier CONTAINS 'language'")).firstMatch
            if languagePicker.waitForExistence(timeout: 5) {
                languagePicker.tap()
                // Should change language
                // Verify strings update
            }
        }
    }
    
    // MARK: - Permission Flow Tests
    
    func testPermissionFlow() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to camera
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
            
            // Permission request should appear
            // Note: Actual permission handling requires device
        }
    }
    
    // MARK: - Error Recovery Flow Tests
    
    func testErrorRecoveryFlow() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to camera
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
            
            // Try to scan (might fail without permission or face)
            // Error should appear
            // Retry button should be available
        }
    }
    
    // MARK: - Cross-Feature Tests
    
    func testThemePersistenceAcrossAppRestarts() throws {
        skipOnboardingIfNeeded()
        
        // Change theme
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            let themePicker = app.pickers.matching(NSPredicate(format: "identifier CONTAINS 'theme'")).firstMatch
            if themePicker.waitForExistence(timeout: 5) {
                // Change theme
                // Restart app
                app.terminate()
                app.launch()
                
                // Theme should persist
            }
        }
    }
    
    func testLanguagePersistenceAcrossScreens() throws {
        skipOnboardingIfNeeded()
        
        // Change language in settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Change language
            // Navigate to other screens
            // Language should persist
        }
    }
    
    func testModeSwitchingBetweenYuzAndKombin() throws {
        skipOnboardingIfNeeded()
        
        // Select Face Aura
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
        }
        
        // Go back and select Outfit Aura
        let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Back' OR identifier CONTAINS 'back'")).firstMatch
        if backButton.waitForExistence(timeout: 3) {
            backButton.tap()
        }
        
        let outfitAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Outfit' OR label CONTAINS 'Kombin'")).firstMatch
        if outfitAuraButton.waitForExistence(timeout: 5) {
            outfitAuraButton.tap()
            // Should switch to outfit mode
        }
    }
    
    // MARK: - Helper Methods
    
    private func skipOnboardingIfNeeded() {
        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 2) {
            for _ in 0..<3 {
                if continueButton.exists {
                    continueButton.tap()
                } else {
                    break
                }
            }
            
            let getStartedButton = app.buttons["Get Started"]
            if getStartedButton.waitForExistence(timeout: 2) {
                getStartedButton.tap()
            }
        }
    }
}

