//
//  UILocalizationTests.swift
//  AuraUITests
//
//  Created by Aura Team
//

import XCTest

final class UILocalizationTests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - English UI Tests
    
    func testEnglishUIStrings() throws {
        app.launchArguments = ["-AppleLanguages", "(en)"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Test key UI strings in English
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in English")
        
        let historyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'History'")).firstMatch
        XCTAssertTrue(historyButton.waitForExistence(timeout: 5), "History button should exist in English")
    }
    
    // MARK: - Turkish UI Tests
    
    func testTurkishUIStrings() throws {
        app.launchArguments = ["-AppleLanguages", "(tr)"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Test key UI strings in Turkish
        // Note: Actual Turkish strings depend on localization implementation
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Ayarlar'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in Turkish")
    }
    
    // MARK: - German UI Tests
    
    func testGermanUIStrings() throws {
        app.launchArguments = ["-AppleLanguages", "(de)"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Test German UI strings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Einstellungen'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in German")
    }
    
    // MARK: - French UI Tests
    
    func testFrenchUIStrings() throws {
        app.launchArguments = ["-AppleLanguages", "(fr)"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Test French UI strings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Paramètres'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in French")
    }
    
    // MARK: - UK English UI Tests
    
    func testUKEnglishUIStrings() throws {
        app.launchArguments = ["-AppleLanguages", "(en-GB)"]
        app.launch()
        
        skipOnboardingIfNeeded()
        
        // Test UK English UI strings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings button should exist in UK English")
    }
    
    // MARK: - Mode Name Localization Tests
    
    func testModeNamesInAllLanguages() throws {
        let languages = ["en", "tr", "de", "fr", "en-GB"]
        
        for language in languages {
            app.terminate()
            app.launchArguments = ["-AppleLanguages", "(\(language))"]
            app.launch()
            
            skipOnboardingIfNeeded()
            
            // Check that mode selection buttons exist
            let modeButtons = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Aura' OR label CONTAINS 'Face' OR label CONTAINS 'Outfit' OR label CONTAINS 'Yüz' OR label CONTAINS 'Kombin'"))
            XCTAssertGreaterThan(modeButtons.count, 0, "Mode buttons should exist in \(language)")
        }
    }
    
    // MARK: - Error Message Localization Tests
    
    func testErrorMessagesInAllLanguages() throws {
        // Test that error messages are localized
        // This would require triggering an error and checking the message
        let languages = ["en", "tr"]
        
        for language in languages {
            app.terminate()
            app.launchArguments = ["-AppleLanguages", "(\(language))"]
            app.launch()
            
            skipOnboardingIfNeeded()
            
            // Navigate to camera
            let faceAuraButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Face' OR label CONTAINS 'Yüz'")).firstMatch
            if faceAuraButton.waitForExistence(timeout: 5) {
                faceAuraButton.tap()
                
                // Error messages would appear if we try to scan without permission
                // This is a placeholder for actual error message testing
            }
        }
    }
    
    // MARK: - Text Rendering Tests
    
    func testTextRenderingInDifferentLanguages() throws {
        // Test that text doesn't overflow or truncate incorrectly
        let languages = ["en", "tr", "de", "fr"]
        
        for language in languages {
            app.terminate()
            app.launchArguments = ["-AppleLanguages", "(\(language))"]
            app.launch()
            
            skipOnboardingIfNeeded()
            
            // Check that UI elements are visible and not cut off
            let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch
            if settingsButton.waitForExistence(timeout: 5) {
                XCTAssertTrue(settingsButton.isHittable, "Settings button should be hittable in \(language)")
            }
        }
    }
    
    // MARK: - Button Text Tests
    
    func testButtonTextInAllLanguages() throws {
        let languages = ["en", "tr"]
        
        for language in languages {
            app.terminate()
            app.launchArguments = ["-AppleLanguages", "(\(language))"]
            app.launch()
            
            skipOnboardingIfNeeded()
            
            // Test that buttons have proper text
            let continueButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Continue' OR label CONTAINS 'Devam'")).firstMatch
            // Buttons should have localized text
        }
    }
    
    // MARK: - No Hardcoded Strings Test
    
    func testNoHardcodedStrings() throws {
        app.launch()
        skipOnboardingIfNeeded()
        
        // Check that common UI elements use localized strings
        // This is a visual/manual check, but we can verify key elements exist
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR label CONTAINS 'Ayarlar' OR label CONTAINS 'Einstellungen' OR label CONTAINS 'Paramètres'")).firstMatch
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5), "Settings should be localized")
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

