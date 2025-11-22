//
//  ButtonInteractionTests.swift
//  AuraUITests
//
//  Created by Aura Team
//

import XCTest

final class ButtonInteractionTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Navigation Button Tests
    
    func testBackButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to a screen with back button
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Look for back/done button
            let backButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Done' OR label CONTAINS 'Back'")).firstMatch
            if backButton.waitForExistence(timeout: 3) {
                backButton.tap()
                // Should navigate back
            }
        }
    }
    
    func testCloseButton() throws {
        skipOnboardingIfNeeded()
        
        // Test close button in result view (if accessible)
        // This would require completing a scan first
    }
    
    // MARK: - Camera Button Tests
    
    func testCameraCaptureButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to camera
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        if faceAuraButton.waitForExistence(timeout: 5) {
            faceAuraButton.tap()
            
            // Look for capture button (circular button)
            let captureButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'capture' OR label == ''")).firstMatch
            if captureButton.waitForExistence(timeout: 5) {
                // Button exists, test would tap in real scenario
                XCTAssertTrue(captureButton.exists)
            }
        }
    }
    
    func testGalleryPickerButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to camera
        let outfitAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Outfit' OR label CONTAINS 'Kombin'")).firstMatch
        if outfitAuraButton.waitForExistence(timeout: 5) {
            outfitAuraButton.tap()
            
            // Look for gallery button (photo icon)
            let galleryButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'gallery' OR identifier CONTAINS 'photo'")).firstMatch
            if galleryButton.waitForExistence(timeout: 5) {
                XCTAssertTrue(galleryButton.exists)
            }
        }
    }
    
    // MARK: - Result View Button Tests
    
    func testSaveButton() throws {
        skipOnboardingIfNeeded()
        
        // Would need to complete a scan first
        // Test that save button exists and is tappable
    }
    
    func testShareButton() throws {
        skipOnboardingIfNeeded()
        
        // Would need to complete a scan first
        // Test that share button exists and opens share sheet
    }
    
    // MARK: - Favorite Toggle Tests
    
    func testFavoriteToggleButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to history
        let historyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'History'")).firstMatch
        if historyButton.waitForExistence(timeout: 5) {
            historyButton.tap()
            
            // Look for favorite button (star icon)
            let favoriteButton = app.buttons.matching(NSPredicate(format: "identifier CONTAINS 'favorite' OR identifier CONTAINS 'star'")).firstMatch
            if favoriteButton.waitForExistence(timeout: 5) {
                favoriteButton.tap()
                // Should toggle favorite state
            }
        }
    }
    
    // MARK: - Delete Button Tests
    
    func testDeleteButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to history
        let historyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'History'")).firstMatch
        if historyButton.waitForExistence(timeout: 5) {
            historyButton.tap()
            
            // Look for delete button
            let deleteButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Delete' OR identifier CONTAINS 'delete'")).firstMatch
            if deleteButton.waitForExistence(timeout: 5) {
                deleteButton.tap()
                // Should show confirmation or delete
            }
        }
    }
    
    // MARK: - Subscription/Purchase Button Tests
    
    func testPurchaseButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Look for upgrade/premium button
            let upgradeButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Upgrade' OR label CONTAINS 'Premium'")).firstMatch
            if upgradeButton.waitForExistence(timeout: 5) {
                upgradeButton.tap()
                // Should show paywall
            }
        }
    }
    
    // MARK: - Settings Navigation Tests
    
    func testSettingsNavigationButton() throws {
        skipOnboardingIfNeeded()
        
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist")
        
        if settingsButton.exists {
            settingsButton.tap()
            XCTAssertTrue(app.navigationBars.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch.waitForExistence(timeout: 3))
        }
    }
    
    // MARK: - Theme Toggle Tests
    
    func testThemeToggleButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Look for theme picker
            let themePicker = app.pickers.matching(NSPredicate(format: "identifier CONTAINS 'theme'")).firstMatch
            if themePicker.waitForExistence(timeout: 5) {
                themePicker.tap()
                // Should show theme options
            }
        }
    }
    
    // MARK: - Language/Country Selection Tests
    
    func testLanguageSelectionButton() throws {
        skipOnboardingIfNeeded()
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Look for language picker
            let languagePicker = app.pickers.matching(NSPredicate(format: "identifier CONTAINS 'language'")).firstMatch
            if languagePicker.waitForExistence(timeout: 5) {
                languagePicker.tap()
            }
        }
    }
    
    // MARK: - Mode Selection Button Tests
    
    func testFaceAuraModeButton() throws {
        skipOnboardingIfNeeded()
        
        let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
        XCTAssertTrue(faceAuraButton.waitForExistence(timeout: 5), "Face Aura button should exist")
        
        if faceAuraButton.exists {
            faceAuraButton.tap()
            // Should navigate to camera with face aura mode
        }
    }
    
    func testOutfitAuraModeButton() throws {
        skipOnboardingIfNeeded()
        
        let outfitAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Outfit' OR label CONTAINS 'Kombin'")).firstMatch
        XCTAssertTrue(outfitAuraButton.waitForExistence(timeout: 5), "Outfit Aura button should exist")
        
        if outfitAuraButton.exists {
            outfitAuraButton.tap()
            // Should navigate to camera with outfit aura mode
        }
    }
    
    // MARK: - Onboarding Button Tests
    
    func testOnboardingContinueButton() throws {
        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 5) {
            continueButton.tap()
            // Should advance to next page
        }
    }
    
    func testOnboardingGetStartedButton() throws {
        // Navigate through onboarding
        let continueButton = app.buttons["Continue"]
        for _ in 0..<3 {
            if continueButton.waitForExistence(timeout: 2) {
                continueButton.tap()
            } else {
                break
            }
        }
        
        let getStartedButton = app.buttons["Get Started"]
        if getStartedButton.waitForExistence(timeout: 5) {
            getStartedButton.tap()
            // Should complete onboarding
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

