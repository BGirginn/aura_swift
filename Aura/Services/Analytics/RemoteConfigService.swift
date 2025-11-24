//
//  RemoteConfigService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

#if canImport(FirebaseRemoteConfig)
import FirebaseRemoteConfig
#endif

/// Service for managing Firebase Remote Config
final class RemoteConfigService {
    
    static let shared = RemoteConfigService()
    
    private var isConfigured = false
    private let queue = DispatchQueue(label: "com.auracolor.remoteconfig", qos: .background)
    
    #if canImport(FirebaseRemoteConfig)
    private let remoteConfig = RemoteConfig.remoteConfig()
    #endif
    
    private init() {
        configure()
    }
    
    // MARK: - Configuration
    
    func configure() {
        guard !isConfigured else { return }
        isConfigured = true
        
        #if canImport(FirebaseRemoteConfig)
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 3600 // 1 hour
        remoteConfig.configSettings = settings
        
        // Set default values
        remoteConfig.setDefaults([
            "ml_enabled": false as NSNumber,
            "daily_scan_limit": 3 as NSNumber
        ])
        
        // Fetch initial config
        fetchConfig()
        #else
        print("ℹ️ RemoteConfigService configured (Firebase Remote Config not linked yet).")
        #endif
    }
    
    // MARK: - Fetch Config
    
    func fetchConfig(completion: ((Bool) -> Void)? = nil) {
        queue.async {
            #if canImport(FirebaseRemoteConfig)
            self.remoteConfig.fetch { status, error in
                if status == .success {
                    self.remoteConfig.activate { _, _ in
                        DispatchQueue.main.async {
                            completion?(true)
                        }
                    }
                } else {
                    print("❌ Failed to fetch Remote Config: \(error?.localizedDescription ?? "unknown")")
                    DispatchQueue.main.async {
                        completion?(false)
                    }
                }
            }
            #else
            DispatchQueue.main.async {
                completion?(false)
            }
            #endif
        }
    }
    
    // MARK: - Get Values
    
    func getBool(for key: String) -> Bool {
        #if canImport(FirebaseRemoteConfig)
        return remoteConfig.configValue(forKey: key).boolValue
        #else
        // Return defaults if Firebase not available
        switch key {
        case "ml_enabled": return false
        default: return false
        }
        #endif
    }
    
    func getInt(for key: String) -> Int {
        #if canImport(FirebaseRemoteConfig)
        return remoteConfig.configValue(forKey: key).numberValue.intValue
        #else
        // Return defaults if Firebase not available
        switch key {
        case "daily_scan_limit": return 3
        default: return 0
        }
        #endif
    }
    
    func getString(for key: String) -> String? {
        #if canImport(FirebaseRemoteConfig)
        let value = remoteConfig.configValue(forKey: key).stringValue
        return value.isEmpty ? nil : value
        #else
        return nil
        #endif
    }
    
    func getJSON(for key: String) -> [String: Any]? {
        #if canImport(FirebaseRemoteConfig)
        guard let data = remoteConfig.configValue(forKey: key).jsonValue as? [String: Any] else {
            return nil
        }
        return data
        #else
        return nil
        #endif
    }
}

