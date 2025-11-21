//
//  AuraUITests.swift
//  AuraUITests
//
//  Created by Aura Team
//

import XCTest

final class AuraUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    // MARK: - Onboarding Flow Tests
    
    func testOnboardingFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Wait for onboarding to appear
        let continueButton = app.buttons["Continue"]
        XCTAssertTrue(continueButton.waitForExistence(timeout: 5), "Onboarding should appear")
        
        // Navigate through onboarding
        if continueButton.exists {
            continueButton.tap()
            
            // Second page
            if continueButton.exists {
                continueButton.tap()
            }
            
            // Get Started button
            let getStartedButton = app.buttons["Get Started"]
            if getStartedButton.exists {
                getStartedButton.tap()
            }
        }
    }
    
    // MARK: - Mode Selection Tests
    
    func testModeSelection() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Skip onboarding if needed
        skipOnboardingIfNeeded(app: app)
        
        // Check for mode selection screen
        let quizButton = app.buttons.matching(identifier: "Personality Quiz").firstMatch
        XCTAssertTrue(quizButton.waitForExistence(timeout: 5) || app.buttons.matching(NSPredicate(format: "label CONTAINS 'Quiz'")).firstMatch.waitForExistence(timeout: 5), "Mode selection should appear")
    }
    
    // MARK: - Quiz Flow Tests
    
    func testQuizFlow() throws {
        let app = XCUIApplication()
        app.launch()
        
        skipOnboardingIfNeeded(app: app)
        
        // Tap quiz mode
        let quizButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Quiz'")).firstMatch
        if quizButton.waitForExistence(timeout: 5) {
            quizButton.tap()
            
            // Answer questions (if quiz loads)
            let nextButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Next' OR label CONTAINS 'Continue'")).firstMatch
            if nextButton.waitForExistence(timeout: 3) {
                // Tap first answer option
                let firstAnswer = app.buttons.firstMatch
                if firstAnswer.exists {
                    firstAnswer.tap()
                    nextButton.tap()
                }
            }
        }
    }
    
    // MARK: - History Tests
    
    func testHistoryNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        skipOnboardingIfNeeded(app: app)
        
        // Navigate to history
        let historyButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'History' OR identifier == 'history'")).firstMatch
        if historyButton.waitForExistence(timeout: 5) {
            historyButton.tap()
            
            // Verify history screen appears
            XCTAssertTrue(app.navigationBars.matching(NSPredicate(format: "label CONTAINS 'History'")).firstMatch.waitForExistence(timeout: 3), "History screen should appear")
        }
    }
    
    // MARK: - Settings Tests
    
    func testSettingsNavigation() throws {
        let app = XCUIApplication()
        app.launch()
        
        skipOnboardingIfNeeded(app: app)
        
        // Navigate to settings
        let settingsButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Settings' OR identifier == 'settings'")).firstMatch
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            
            // Verify settings screen appears
            XCTAssertTrue(app.navigationBars.matching(NSPredicate(format: "label CONTAINS 'Settings'")).firstMatch.waitForExistence(timeout: 3), "Settings screen should appear")
        }
    }
    
    // MARK: - Helper Methods
    
    private func skipOnboardingIfNeeded(app: XCUIApplication) {
        let continueButton = app.buttons["Continue"]
        if continueButton.waitForExistence(timeout: 2) {
            // Skip through onboarding
            for _ in 0..<3 {
                if continueButton.exists {
                    continueButton.tap()
                } else {
                    break
                }
            }
            
            // Tap Get Started
            let getStartedButton = app.buttons["Get Started"]
            if getStartedButton.waitForExistence(timeout: 2) {
                getStartedButton.tap()
            }
        }
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}

