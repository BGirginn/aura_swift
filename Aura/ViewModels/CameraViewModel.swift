//
//  CameraViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import AVFoundation
import Combine

/// ViewModel for camera capture and aura detection
class CameraViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isProcessing = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var permissionStatus: AVAuthorizationStatus = .notDetermined
    @Published var capturedImage: UIImage?
    @Published var detectedAuraResult: AuraResult?
    
    // MARK: - Dependencies
    
    private let auraDetectionService: AuraDetectionServiceProtocol
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(auraDetectionService: AuraDetectionServiceProtocol = AuraDetectionService(),
         dataManager: DataManager = .shared) {
        self.auraDetectionService = auraDetectionService
        self.dataManager = dataManager
        checkCameraPermission()
    }
    
    // MARK: - Camera Permission
    
    func checkCameraPermission() {
        permissionStatus = AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    func requestCameraPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.permissionStatus = granted ? .authorized : .denied
                
                // Log analytics
                if granted {
                    self?.logEvent(.cameraPermissionGranted)
                } else {
                    self?.logEvent(.cameraPermissionDenied)
                }
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
    
    // MARK: - Image Processing
    
    func processImage(_ image: UIImage) {
        isProcessing = true
        errorMessage = nil
        capturedImage = image
        
        logEvent(.scanStarted)
        
        auraDetectionService.detectAura(from: image) { [weak self] result in
            DispatchQueue.main.async {
                self?.isProcessing = false
                
                switch result {
                case .success(let auraResult):
                    self?.handleSuccessfulScan(auraResult)
                case .failure(let error):
                    self?.handleScanError(error)
                }
            }
        }
    }
    
    private func handleSuccessfulScan(_ result: AuraResult) {
        detectedAuraResult = result
        
        // Save to history
        do {
            try dataManager.saveAuraResult(result)
        } catch {
            print("Failed to save result: \(error.localizedDescription)")
        }
        
        // Log analytics
        logEvent(.scanCompleted, parameters: [
            "primary_color": result.primaryColor.id,
            "has_secondary": result.secondaryColor != nil,
            "has_tertiary": result.tertiaryColor != nil
        ])
        
        // Post notification
        NotificationCenter.default.post(name: .didCompleteScan, object: result)
    }
    
    private func handleScanError(_ error: AuraDetectionError) {
        errorMessage = error.errorDescription
        showError = true
        
        logEvent(.scanFailed, parameters: [
            "error": error.localizedDescription
        ])
    }
    
    // MARK: - Daily Limit Check
    
    func canScanToday() -> Bool {
        // Check if user is premium
        let isPremium = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremiumUser)
        if isPremium {
            return true
        }
        
        // Check daily scan count
        let today = Calendar.current.startOfDay(for: Date())
        let lastScanDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScanDate) as? Date
        let dailyScanCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dailyScanCount)
        
        if let lastScanDate = lastScanDate,
           Calendar.current.isDate(lastScanDate, inSameDayAs: today) {
            return dailyScanCount < ScanLimits.freeDailyLimit
        }
        
        // New day, reset counter
        return true
    }
    
    func incrementDailyCount() {
        let today = Calendar.current.startOfDay(for: Date())
        let lastScanDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScanDate) as? Date
        
        if let lastScanDate = lastScanDate,
           Calendar.current.isDate(lastScanDate, inSameDayAs: today) {
            let currentCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dailyScanCount)
            UserDefaults.standard.set(currentCount + 1, forKey: UserDefaultsKeys.dailyScanCount)
        } else {
            // New day
            UserDefaults.standard.set(1, forKey: UserDefaultsKeys.dailyScanCount)
            UserDefaults.standard.set(today, forKey: UserDefaultsKeys.lastScanDate)
        }
    }
    
    func getRemainingScans() -> Int {
        let isPremium = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremiumUser)
        if isPremium {
            return Int.max
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let lastScanDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.lastScanDate) as? Date
        let dailyScanCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.dailyScanCount)
        
        if let lastScanDate = lastScanDate,
           Calendar.current.isDate(lastScanDate, inSameDayAs: today) {
            return max(0, ScanLimits.freeDailyLimit - dailyScanCount)
        }
        
        return ScanLimits.freeDailyLimit
    }
    
    // MARK: - Analytics
    
    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        // Placeholder for analytics implementation
        print("Analytics Event: \(event.rawValue), parameters: \(parameters)")
    }
    
    // MARK: - Reset
    
    func reset() {
        capturedImage = nil
        detectedAuraResult = nil
        errorMessage = nil
        showError = false
        isProcessing = false
    }
}

