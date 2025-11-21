//
//  AuthService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import AuthenticationServices
import Combine

/// Service for handling user authentication
@MainActor
class AuthService: NSObject, ObservableObject {
    
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isGuestMode = true
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private override init() {
        super.init()
        loadUserState()
    }
    
    // MARK: - User State
    
    private func loadUserState() {
        // Load from UserDefaults
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            currentUser = user
            isAuthenticated = true
            isGuestMode = false
        } else {
            // Guest mode
            currentUser = User()
            isAuthenticated = false
            isGuestMode = true
        }
    }
    
    private func saveUserState() {
        if let user = currentUser,
           let userData = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(userData, forKey: "currentUser")
        }
    }
    
    // MARK: - Sign In with Apple
    
    func signInWithApple() {
        isLoading = true
        errorMessage = nil
        
        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    // MARK: - Guest Mode
    
    func continueAsGuest() {
        currentUser = User()
        isAuthenticated = false
        isGuestMode = true
        saveUserState()
        AnalyticsService.shared.logEvent(.onboardingCompleted, parameters: ["mode": "guest"])
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        isGuestMode = true
        UserDefaults.standard.removeObject(forKey: "currentUser")
        AnalyticsService.shared.logEvent(.userSignedOut)
    }
    
    // MARK: - User Profile
    
    func updateUserProfile(countryCode: String, languageCode: String) {
        guard var user = currentUser else { return }
        user.countryCode = countryCode
        user.languageCode = languageCode
        currentUser = user
        saveUserState()
    }
    
    func updateSubscriptionStatus(hasPremium: Bool, plan: User.SubscriptionPlan?, expiresAt: Date?) {
        guard var user = currentUser else { return }
        user.hasPremium = hasPremium
        user.subscriptionPlan = plan
        user.subscriptionExpiresAt = expiresAt
        currentUser = user
        saveUserState()
    }
    
    func updateCredits(_ credits: Int) {
        guard var user = currentUser else { return }
        user.credits = credits
        currentUser = user
        saveUserState()
    }
    
    func addCredits(_ amount: Int) {
        guard var user = currentUser else { return }
        user.credits += amount
        currentUser = user
        saveUserState()
    }
    
    func consumeCredit() -> Bool {
        guard var user = currentUser else { return false }
        if user.hasPremium {
            return true // Unlimited for premium
        }
        if user.credits > 0 {
            user.credits -= 1
            currentUser = user
            saveUserState()
            return true
        }
        return false
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AuthService: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            
            // Create user from Apple ID
            var newUser = User(
                id: userIdentifier,
                countryCode: currentUser?.countryCode ?? Locale.current.region?.identifier ?? "US",
                languageCode: currentUser?.languageCode ?? Locale.current.languageCode ?? "en",
                hasPremium: currentUser?.hasPremium ?? false,
                credits: currentUser?.credits ?? 0
            )
            
            // Update with Apple ID info if available
            if let email = email {
                // Store email if needed
            }
            
            currentUser = newUser
            isAuthenticated = true
            isGuestMode = false
            isLoading = false
            saveUserState()
            
            AnalyticsService.shared.logEvent(.userSignedIn, parameters: ["method": "apple"])
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        errorMessage = error.localizedDescription
        isLoading = false
        AnalyticsService.shared.logEvent(.errorOccurred, parameters: [
            "error_name": "SignInFailed",
            "error_description": error.localizedDescription
        ])
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return UIApplication.shared.windows.first { $0.isKeyWindow } ?? UIWindow()
    }
}

