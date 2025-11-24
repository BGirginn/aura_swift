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
        // Remove existing inputs and outputs first
        session.beginConfiguration()
        
        // Remove existing inputs
        session.inputs.forEach { session.removeInput($0) }
        
        // Remove existing outputs
        session.outputs.forEach { session.removeOutput($0) }
        
        session.sessionPreset = .photo
        
        // Add video input
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let videoInput = try? AVCaptureDeviceInput(device: videoDevice),
              session.canAddInput(videoInput) else {
            print("⚠️ Failed to setup video input")
            session.commitConfiguration()
            return
        }
        
        session.addInput(videoInput)
        
        // Add photo output
        guard session.canAddOutput(photoOutput) else {
            print("⚠️ Failed to add photo output")
            session.commitConfiguration()
            return
        }
        
        session.addOutput(photoOutput)
        photoOutput.maxPhotoQualityPrioritization = .quality
        
        // Configure photo output connections after adding to session
        session.commitConfiguration()
        
        // Configure connections after commit
        if let connection = photoOutput.connections.first {
            if connection.isVideoMirroringSupported {
                connection.isVideoMirrored = true
            }
            if connection.isVideoStabilizationSupported {
                connection.preferredVideoStabilizationMode = .auto
            }
        }
        
        print("✅ Camera session setup completed with \(photoOutput.connections.count) connections")
    }
    
    // MARK: - Session Control
    
    func startSession() {
        guard !session.isRunning else {
            print("✅ Camera session already running")
            DispatchQueue.main.async { [weak self] in
                self?.isSessionRunning = true
            }
            return
        }
        
        // Ensure session is set up
        if session.inputs.isEmpty || session.outputs.isEmpty {
            print("⚠️ Session not set up, setting up now...")
            setupSession()
        }
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            self.session.startRunning()
            
            DispatchQueue.main.async {
                self.isSessionRunning = self.session.isRunning
                if self.isSessionRunning {
                    print("✅ Camera session started successfully")
                } else {
                    print("⚠️ Camera session failed to start")
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
        // Check if session is running
        guard session.isRunning else {
            print("⚠️ Cannot capture photo: Session is not running")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Check if photo output has connections
        guard !photoOutput.connections.isEmpty else {
            print("⚠️ Cannot capture photo: No photo output connections")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Find video connection (should be first connection after setup)
        let videoConnection = photoOutput.connections.first { connection in
            connection.inputPorts.contains { port in
                port.mediaType == .video
            }
        }
        
        guard let connection = videoConnection else {
            print("⚠️ Cannot capture photo: No video connection found")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        // Ensure connection is enabled
        guard connection.isEnabled else {
            print("⚠️ Cannot capture photo: Video connection is disabled")
            DispatchQueue.main.async {
                completion(nil)
            }
            return
        }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = .off
        
        self.photoCompletion = completion
        self.currentPhotoSettings = settings
        
        // Capture photo - must be called on session queue or main thread when session is running
        if Thread.isMainThread {
            photoOutput.capturePhoto(with: settings, delegate: self)
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.session.isRunning else {
                    completion(nil)
                    return
                }
                self.photoOutput.capturePhoto(with: settings, delegate: self)
            }
        }
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

