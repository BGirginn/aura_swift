//
//  AuthViewModelTests.swift
//  AuraTests
//
//  Created by Aura Team
//

import XCTest
import Combine
@testable import Aura

@MainActor
final class AuthViewModelTests: XCTestCase {
    
    var viewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        cancellables = Set<AnyCancellable>()
        viewModel = AuthViewModel()
    }
    
    override func tearDownWithError() throws {
        cancellables = nil
        viewModel = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialState() {
        // ViewModel should reflect AuthService state
        XCTAssertNotNil(viewModel.currentUser)
    }
    
    // MARK: - Guest Mode Tests
    
    func testContinueAsGuest() {
        let expectation = XCTestExpectation(description: "Guest mode activated")
        
        viewModel.$isGuestMode
            .dropFirst()
            .sink { isGuest in
                if isGuest {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.continueAsGuest()
        
        wait(for: [expectation], timeout: 2.0)
        XCTAssertTrue(viewModel.isGuestMode)
    }
    
    // MARK: - Profile Update Tests
    
    func testUpdateProfile() {
        viewModel.continueAsGuest()
        
        viewModel.updateProfile(countryCode: "TR", languageCode: "tr")
        
        XCTAssertEqual(viewModel.currentUser?.countryCode, "TR")
        XCTAssertEqual(viewModel.currentUser?.languageCode, "tr")
    }
    
    // MARK: - Sign Out Tests
    
    func testSignOut() {
        viewModel.continueAsGuest()
        viewModel.updateProfile(countryCode: "US", languageCode: "en")
        
        viewModel.signOut()
        
        XCTAssertTrue(viewModel.isGuestMode)
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    // MARK: - State Binding Tests
    
    func testAuthenticationStateBinding() {
        let expectation = XCTestExpectation(description: "State updated")
        
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { _ in
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        viewModel.continueAsGuest()
        
        wait(for: [expectation], timeout: 2.0)
    }
}

