//
//  AuthViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import Combine
import SwiftUI

@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var isGuestMode = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentUser: User?
    
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    init(authService: AuthService = .shared) {
        self.authService = authService
        setupBindings()
    }
    
    private func setupBindings() {
        authService.$currentUser
            .assign(to: &$currentUser)
        
        authService.$isAuthenticated
            .assign(to: &$isAuthenticated)
        
        authService.$isGuestMode
            .assign(to: &$isGuestMode)
        
        authService.$isLoading
            .assign(to: &$isLoading)
        
        authService.$errorMessage
            .assign(to: &$errorMessage)
    }
    
    // MARK: - Actions
    
    func signInWithApple() {
        authService.signInWithApple()
    }
    
    func continueAsGuest() {
        authService.continueAsGuest()
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func updateProfile(countryCode: String, languageCode: String) {
        authService.updateUserProfile(countryCode: countryCode, languageCode: languageCode)
    }
}

