//
//  StorageService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import Combine

/// Unified storage service for local and cloud operations
class StorageService {
    
    static let shared = StorageService()
    
    private let dataManager: DataManager
    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()
    
    // Cloud sync enabled flag (can be controlled by RemoteConfig)
    var cloudSyncEnabled: Bool {
        // For now, return false. Can be enabled when Firebase is configured
        #if FIREBASE_ENABLED
        return authService.isAuthenticated && !authService.isGuestMode
        #else
        return false
        #endif
    }
    
    private init(dataManager: DataManager = .shared,
                 authService: AuthService = .shared) {
        self.dataManager = dataManager
        self.authService = authService
    }
    
    // MARK: - Local Operations
    
    /// Save aura result locally
    func saveAuraResult(_ result: AuraResult) throws {
        try dataManager.saveAuraResult(result)
        
        // If cloud sync is enabled, also save to cloud
        if cloudSyncEnabled {
            syncToCloud(result)
        }
        
        AnalyticsService.shared.logEvent(.resultSaved, parameters: [
            "primary_color": result.primaryColor.id,
            "country_code": result.countryCode
        ])
    }
    
    /// Fetch paginated history
    func fetchHistory(page: Int = 0, pageSize: Int = 20) throws -> [AuraResult] {
        // For now, return all. Can be enhanced with pagination
        return try dataManager.fetchAllHistory()
    }
    
    /// Fetch favorites
    func fetchFavorites() throws -> [AuraResult] {
        return try dataManager.fetchFavorites()
    }
    
    /// Delete history item
    func deleteHistory(_ result: AuraResult) throws {
        try dataManager.deleteHistory(result)
        
        // If cloud sync is enabled, also delete from cloud
        if cloudSyncEnabled {
            deleteFromCloud(result)
        }
    }
    
    /// Toggle favorite
    func toggleFavorite(_ result: AuraResult) throws {
        try dataManager.toggleFavorite(result)
        
        // If cloud sync is enabled, update cloud
        if cloudSyncEnabled {
            updateFavoriteInCloud(result)
        }
    }
    
    /// Delete all history
    func deleteAllHistory() throws {
        try dataManager.deleteAllHistory()
        
        // If cloud sync is enabled, clear cloud
        if cloudSyncEnabled {
            clearCloudHistory()
        }
    }
    
    // MARK: - User Settings
    
    /// Save user settings
    func saveUserSettings(countryCode: String, languageCode: String, savePhotos: Bool, analyticsEnabled: Bool) {
        UserDefaults.standard.set(countryCode, forKey: UserDefaultsKeys.selectedCountryCode)
        UserDefaults.standard.set(languageCode, forKey: UserDefaultsKeys.selectedLanguage)
        // Add more settings as needed
        
        // If cloud sync is enabled, sync settings
        if cloudSyncEnabled {
            syncSettingsToCloud(countryCode: countryCode, languageCode: languageCode)
        }
    }
    
    // MARK: - Cloud Operations (Firebase/Supabase)
    
    #if FIREBASE_ENABLED
    private func syncToCloud(_ result: AuraResult) {
        // TODO: Implement Firebase Firestore sync
        // This would upload the aura result metadata to Firestore
        // under users/{userId}/aura_results/{resultId}
    }
    
    private func deleteFromCloud(_ result: AuraResult) {
        // TODO: Implement Firebase Firestore delete
    }
    
    private func updateFavoriteInCloud(_ result: AuraResult) {
        // TODO: Implement Firebase Firestore update
    }
    
    private func clearCloudHistory() {
        // TODO: Implement Firebase Firestore batch delete
    }
    
    private func syncSettingsToCloud(countryCode: String, languageCode: String) {
        // TODO: Implement Firebase Firestore settings sync
    }
    
    /// Sync all local data to cloud
    func syncAllToCloud() {
        guard cloudSyncEnabled else { return }
        
        // Fetch all local results and sync
        do {
            let results = try dataManager.fetchAllHistory()
            for result in results {
                syncToCloud(result)
            }
        } catch {
            print("Failed to sync to cloud: \(error)")
        }
    }
    
    /// Download cloud data and merge with local
    func syncFromCloud() {
        guard cloudSyncEnabled else { return }
        
        // TODO: Implement Firebase Firestore download
        // This would fetch aura_results from cloud and merge with local data
    }
    #else
    private func syncToCloud(_ result: AuraResult) {}
    private func deleteFromCloud(_ result: AuraResult) {}
    private func updateFavoriteInCloud(_ result: AuraResult) {}
    private func clearCloudHistory() {}
    private func syncSettingsToCloud(countryCode: String, languageCode: String) {}
    func syncAllToCloud() {}
    func syncFromCloud() {}
    #endif
}

