//
//  PermissionManager.swift
//  Aura
//
//  Created by Aura Team
//

import AVFoundation
import Photos
import UIKit

/// Manager for handling app permissions
@MainActor
class PermissionManager: ObservableObject {
    
    static let shared = PermissionManager()
    
    @Published var cameraStatus: AVAuthorizationStatus = .notDetermined
    @Published var photoLibraryStatus: PHAuthorizationStatus = .notDetermined
    
    private init() {
        checkPermissions()
    }
    
    // MARK: - Check Permissions
    
    func checkPermissions() {
        cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)
        photoLibraryStatus = PHPhotoLibrary.authorizationStatus()
    }
    
    // MARK: - Camera Permission
    
    func requestCameraPermission(completion: @escaping (Bool) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            DispatchQueue.main.async {
                self?.cameraStatus = granted ? .authorized : .denied
                completion(granted)
            }
        }
    }
    
    var hasCameraPermission: Bool {
        return cameraStatus == .authorized
    }
    
    // MARK: - Photo Library Permission
    
    func requestPhotoLibraryPermission(completion: @escaping (Bool) -> Void) {
        PHPhotoLibrary.requestAuthorization { [weak self] status in
            DispatchQueue.main.async {
                self?.photoLibraryStatus = status
                completion(status == .authorized)
            }
        }
    }
    
    var hasPhotoLibraryPermission: Bool {
        return photoLibraryStatus == .authorized
    }
    
    // MARK: - Open Settings
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

