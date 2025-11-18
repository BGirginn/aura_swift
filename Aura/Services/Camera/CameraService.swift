//
//  CameraService.swift
//  Aura
//
//  Created by Aura Team
//

import AVFoundation
import UIKit

/// Service for camera capture functionality
class CameraService: NSObject, ObservableObject {
    
    @Published var isSessionRunning = false
    @Published var capturedPhoto: UIImage?
    
    let session = AVCaptureSession()
    private let photoOutput = AVCapturePhotoOutput()
    private var currentPhotoSettings: AVCapturePhotoSettings?
    private var photoCompletion: ((UIImage?) -> Void)?
    
    override init() {
        super.init()
        checkPermissions()
    }
    
    // MARK: - Permissions
    
    func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            requestPermission()
        default:
            break
        }
    }
    
    private func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
            if granted {
                DispatchQueue.main.async {
                    self?.setupSession()
                }
            }
        }
    }
    
    // MARK: - Session Setup
    
    func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            session.commitConfiguration()
            return
        }
        
        session.addInput(videoInput)
        
        // Add photo output
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            photoOutput.maxPhotoQualityPrioritization = .quality
        }
        
        session.commitConfiguration()
    }
    
    // MARK: - Session Control
    
    func startSession() {
        if !session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.startRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = true
                }
            }
        }
    }
    
    func stopSession() {
        if session.isRunning {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.session.stopRunning()
                DispatchQueue.main.async {
                    self?.isSessionRunning = false
                }
            }
        }
    }
    
    // MARK: - Capture Photo
    
    func capturePhoto(completion: @escaping (UIImage?) -> Void) {
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        self.photoCompletion = completion
        self.currentPhotoSettings = settings
        
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil,
              let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData) else {
            photoCompletion?(nil)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.capturedPhoto = image
            self?.photoCompletion?(image)
            self?.photoCompletion = nil
        }
    }
}

