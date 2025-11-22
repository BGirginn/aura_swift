//
//  LocalizationTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
@testable import Aura

final class LocalizationTests: XCTestCase {
    
    var localizationService: LocalizationService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        localizationService = LocalizationService.shared
    }
    
    // MARK: - Multi-Language Tests
    
    func testAllSupportedLanguages() throws {
        let languages: [String] = ["en", "tr", "de", "fr", "uk"]
        
        for language in languages {
            localizationService.setLanguage(language)
            let currentLang = localizationService.getCurrentLanguage()
            XCTAssertEqual(currentLang, language, "Language should be set to \(language)")
        }
    }
    
    func testStringLoadingForEachLanguage() throws {
        let testKey = "onboarding.page1.title"
        let languages: [String] = ["en", "tr", "de", "fr", "uk"]
        
        for language in languages {
            localizationService.setLanguage(language)
            let string = NSLocalizedString(testKey, comment: "")
            XCTAssertFalse(string.isEmpty, "String should be loaded for \(language)")
            XCTAssertNotEqual(string, testKey, "String should be translated, not return key")
        }
    }
    
    func testAuraDescriptionsPerCountry() throws {
        let countries: [String] = ["US", "TR", "UK", "DE", "FR"]
        let testColor = AuraColor.blue
        
        for country in countries {
            localizationService.setCountryCode(country)
            let description = localizationService.getDescription(for: testColor, countryCode: country)
            XCTAssertNotNil(description, "Description should exist for \(country)")
        }
    }
    
    func testFallbackMechanisms() throws {
        // Test with invalid country code
        let description = localizationService.getDescription(for: AuraColor.red, countryCode: "XX")
        // Should fallback to default (US or English)
        XCTAssertNotNil(description)
    }
    
    func testLanguageSwitching() throws {
        localizationService.setLanguage("en")
        XCTAssertEqual(localizationService.getCurrentLanguage(), "en")
        
        localizationService.setLanguage("tr")
        XCTAssertEqual(localizationService.getCurrentLanguage(), "tr")
        
        localizationService.setLanguage("de")
        XCTAssertEqual(localizationService.getCurrentLanguage(), "de")
    }
    
    func testCountrySpecificContent() throws {
        let testColor = AuraColor.green
        
        // Test US content
        localizationService.setCountryCode("US")
        let usDescription = localizationService.getDescription(for: testColor, countryCode: "US")
        
        // Test TR content
        localizationService.setCountryCode("TR")
        let trDescription = localizationService.getDescription(for: testColor, countryCode: "TR")
        
        // Descriptions might be different or same, but both should exist
        XCTAssertNotNil(usDescription)
        XCTAssertNotNil(trDescription)
    }
    
    // MARK: - Date/Time Formatting Tests
    
    func testDateFormattingPerLocale() throws {
        let date = Date()
        let formatter = DateFormatter()
        
        // Test US format
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateStyle = .medium
        let usFormat = formatter.string(from: date)
        XCTAssertFalse(usFormat.isEmpty)
        
        // Test TR format
        formatter.locale = Locale(identifier: "tr_TR")
        let trFormat = formatter.string(from: date)
        XCTAssertFalse(trFormat.isEmpty)
        
        // Formats should be different
        XCTAssertNotEqual(usFormat, trFormat)
    }
    
    func testNumberFormattingPerLocale() throws {
        let number = 1234.56
        let formatter = NumberFormatter()
        
        // Test US format
        formatter.locale = Locale(identifier: "en_US")
        formatter.numberStyle = .decimal
        let usFormat = formatter.string(from: NSNumber(value: number))
        XCTAssertNotNil(usFormat)
        
        // Test TR format (uses comma as decimal separator)
        formatter.locale = Locale(identifier: "tr_TR")
        let trFormat = formatter.string(from: NSNumber(value: number))
        XCTAssertNotNil(trFormat)
    }
    
    // MARK: - Aura Color Localization Tests
    
    func testAuraColorDescriptionsInAllLanguages() throws {
        let colors: [AuraColor] = [.red, .orange, .yellow, .green, .blue, .purple, .pink, .white]
        let languages: [String] = ["en", "tr", "de", "fr", "uk"]
        
        for color in colors {
            for language in languages {
                localizationService.setLanguage(language)
                let description = localizationService.getDescription(for: color)
                XCTAssertNotNil(description, "Description should exist for \(color.name) in \(language)")
            }
        }
    }
    
    func testAuraStoriesInAllLanguages() throws {
        let colors: [AuraColor] = [.red, .blue, .green]
        let languages: [String] = ["en", "tr"]
        
        for color in colors {
            for language in languages {
                localizationService.setLanguage(language)
                let story = localizationService.getStory(for: color, countryCode: "US")
                XCTAssertFalse(story.isEmpty, "Story should exist for \(color.name) in \(language)")
            }
        }
    }
}

