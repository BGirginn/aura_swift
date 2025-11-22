//
//  AnalyticsService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

#if canImport(FirebaseCore)
import FirebaseCore
#endif

#if canImport(FirebaseAnalytics)
import FirebaseAnalytics
#endif

/// Central analytics router (Firebase, Crashlytics, etc.)
final class AnalyticsService {
    
    static let shared = AnalyticsService()
    
    private var isConfigured = false
    private let queue = DispatchQueue(label: "com.auracolor.analytics", qos: .background)
    
    private init() {}
    
    func configure() {
        guard !isConfigured else { return }
        isConfigured = true
        
        #if canImport(FirebaseCore)
        FirebaseApp.configure()
        #else
        print("ℹ️ AnalyticsService configured (Firebase not linked yet).")
        #endif
    }
    
    func logEvent(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        queue.async {
            #if canImport(FirebaseAnalytics)
            Analytics.logEvent(event.rawValue, parameters: parameters)
            #else
            print("📊 Analytics Event -> \(event.rawValue) : \(parameters)")
            #endif
        }
    }
    
    func logScreen(_ name: String) {
        logEvent(.screenView, parameters: ["screen_name": name])
        
        #if canImport(FirebaseAnalytics)
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: name
        ])
        #else
        print("🖥️ Screen View -> \(name)")
        #endif
    }
    
    func setUserProperty(_ value: String?, for key: String) {
        queue.async {
            #if canImport(FirebaseAnalytics)
            Analytics.setUserProperty(value, forName: key)
            #else
            let displayValue = value ?? "nil"
            print("👤 User Property -> \(key): \(displayValue)")
            #endif
        }
    }
}


