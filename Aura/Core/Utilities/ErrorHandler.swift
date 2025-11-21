//
//  ErrorHandler.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation
import SwiftUI

/// Centralized error handling
class ErrorHandler: ObservableObject {
    
    static let shared = ErrorHandler()
    
    @Published var currentError: AppError?
    @Published var showError = false
    
    private init() {}
    
    func handle(_ error: Error) {
        if let appError = error as? AppError {
            currentError = appError
        } else {
            currentError = .generic(error.localizedDescription)
        }
        showError = true
        
        // Log to analytics
        logError(error)
        
        // Haptic feedback
        HapticManager.shared.error()
    }
    
    func handle(_ appError: AppError) {
        currentError = appError
        showError = true
        
        // Log to analytics
        logError(appError)
        
        // Haptic feedback
        HapticManager.shared.error()
    }
    
    private func logError(_ error: Error) {
        // Log to console
        print("❌ Error: \(error.localizedDescription)")
        
        // Send to analytics service
        let errorName: String
        let errorDescription: String
        
        if let appError = error as? AppError {
            errorName = String(describing: appError)
            errorDescription = appError.localizedDescription
        } else {
            errorName = String(describing: type(of: error))
            errorDescription = error.localizedDescription
        }
        
        AnalyticsService.shared.logEvent(.errorOccurred, parameters: [
            "error_name": errorName,
            "error_description": errorDescription,
            "error_domain": (error as NSError).domain,
            "error_code": (error as NSError).code
        ])
    }
    
    func clearError() {
        currentError = nil
        showError = false
    }
}

// MARK: - App Errors

enum AppError: LocalizedError {
    case noFaceDetected
    case imageTooSmall
    case processingFailed
    case invalidImage
    case noAuraColorFound
    case cameraPermissionDenied
    case photoLibraryPermissionDenied
    case dailyLimitReached
    case networkError
    case purchaseFailed
    case generic(String)
    
    var errorDescription: String? {
        switch self {
        case .noFaceDetected:
            return NSLocalizedString("error.noFaceDetected", comment: "")
        case .imageTooSmall:
            return "Image resolution is too small for accurate detection"
        case .processingFailed:
            return NSLocalizedString("error.processingFailed", comment: "")
        case .invalidImage:
            return "Invalid image format"
        case .noAuraColorFound:
            return "Could not determine aura colors"
        case .cameraPermissionDenied:
            return NSLocalizedString("camera.permission.message", comment: "")
        case .photoLibraryPermissionDenied:
            return "Photo library access is required"
        case .dailyLimitReached:
            return NSLocalizedString("error.dailyLimitReached", comment: "")
        case .networkError:
            return "Network connection error. Please check your internet connection."
        case .purchaseFailed:
            return "Purchase failed. Please try again."
        case .generic(let message):
            return message
        }
    }
}

// MARK: - Error View

struct ErrorView: View {
    
    let error: AppError
    let retry: (() -> Void)?
    let dismiss: () -> Void
    
    var body: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Error")
                .font(.title.bold())
                .foregroundColor(.auraText)
            
            Text(error.localizedDescription)
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutConstants.largePadding)
            
            HStack(spacing: LayoutConstants.padding) {
                if let retry = retry {
                    Button(action: retry) {
                        Text("Retry")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: LayoutConstants.buttonHeight)
                            .background(Color.auraAccent)
                            .cornerRadius(LayoutConstants.cornerRadius)
                    }
                }
                
                Button(action: dismiss) {
                    Text("OK")
                        .font(.headline)
                        .foregroundColor(.auraAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutConstants.buttonHeight)
                        .background(Color.auraSurface)
                        .cornerRadius(LayoutConstants.cornerRadius)
                }
            }
            .padding(.horizontal, LayoutConstants.largePadding)
        }
        .padding()
    }
}

