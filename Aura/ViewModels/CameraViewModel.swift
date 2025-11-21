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
    let cameraService: CameraService  // Public for CameraPreviewView access
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init(auraDetectionService: AuraDetectionServiceProtocol = AuraDetectionService(),
         dataManager: DataManager = .shared,
         cameraService: CameraService = CameraService()) {
        self.auraDetectionService = auraDetectionService
        self.dataManager = dataManager
        self.cameraService = cameraService
        checkCameraPermission()
    }
    
    // MARK: - Camera Control
    
    func startCamera() {
        cameraService.startSession()
    }
    
    func stopCamera() {
        cameraService.stopSession()
    }
    
    func capturePhoto() {
        isProcessing = true
        cameraService.capturePhoto { [weak self] image in
            guard let image = image else {
                self?.isProcessing = false
                return
            }
            self?.processImage(image)
        }
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
    
    func processImage(_ image: UIImage, mode: AuraMode = .faceDetection) {
        isProcessing = true
        errorMessage = nil
        capturedImage = image.fixedOrientation()
        
        logEvent(.scanStarted)
        
        switch mode {
        case .faceDetection:
            // Use face detection mode
            auraDetectionService.detectAura(from: capturedImage!) { [weak self] result in
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
            
        case .photoAnalysis:
            // Use photo analysis mode (no face detection)
            let photoAnalysisService = PhotoAnalysisService()
            photoAnalysisService.analyzePhoto(image) { [weak self] result in
                DispatchQueue.main.async {
                    self?.isProcessing = false
                    
                    if let result = result {
                        self?.handleSuccessfulScan(result)
                    } else {
                        self?.handleScanError(.processingFailed)
                    }
                }
            }
            
        case .quiz:
            // Quiz mode doesn't use image processing
            break
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
        
        // Track user satisfaction for rate prompt
        RateAppManager.shared.recordScanCompletion()
        
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
    
    // MARK: - Daily Limit Check (Disabled for now)
    
    func canScanToday() -> Bool {
        // Always return true for base version
        return true
    }
    
    func incrementDailyCount() {
        // Disabled for base version
    }
    
    func getRemainingScans() -> Int {
        // Always return unlimited for base version
        return Int.max
    }
    
    // MARK: - Analytics
    
    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        AnalyticsService.shared.logEvent(event, parameters: parameters)
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

