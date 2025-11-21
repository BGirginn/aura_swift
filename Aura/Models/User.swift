//
//  User.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Represents a user with subscription and credit information
struct User: Identifiable, Codable {
    let id: String
    var countryCode: String
    var languageCode: String
    var hasPremium: Bool
    var credits: Int
    var subscriptionPlan: SubscriptionPlan?
    var subscriptionExpiresAt: Date?
    
    enum SubscriptionPlan: String, Codable {
        case monthly = "monthly"
        case yearly = "yearly"
    }
    
    init(id: String = UUID().uuidString,
         countryCode: String = Locale.current.region?.identifier ?? "US",
         languageCode: String = Locale.current.languageCode ?? "en",
         hasPremium: Bool = false,
         credits: Int = 0,
         subscriptionPlan: SubscriptionPlan? = nil,
         subscriptionExpiresAt: Date? = nil) {
        self.id = id
        self.countryCode = countryCode
        self.languageCode = languageCode
        self.hasPremium = hasPremium
        self.credits = credits
        self.subscriptionPlan = subscriptionPlan
        self.subscriptionExpiresAt = subscriptionExpiresAt
    }
    
    var isSubscriptionActive: Bool {
        guard let expiresAt = subscriptionExpiresAt else { return false }
        return expiresAt > Date() && hasPremium
    }
    
    var canScan: Bool {
        return hasPremium || credits > 0
    }
}

