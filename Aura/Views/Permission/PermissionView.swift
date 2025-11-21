//
//  PermissionView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import AVFoundation
import Photos

struct PermissionView: View {
    
    @ObservedObject var coordinator: AppCoordinator
    @StateObject private var permissionManager = PermissionManager.shared
    @State private var showCameraPermission = false
    @State private var showPhotoPermission = false
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack(spacing: LayoutConstants.largePadding) {
                Spacer()
                
                // Icon
                Image(systemName: "camera.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.auraAccent)
                
                // Title
                Text("Camera & Photo Access")
                    .font(.title.bold())
                    .foregroundColor(.auraText)
                    .multilineTextAlignment(.center)
                
                // Description
                VStack(alignment: .leading, spacing: LayoutConstants.padding) {
                    PermissionRow(
                        icon: "camera",
                        title: "Camera Access",
                        description: "We need camera access to scan your aura in real-time. Your photos are processed on-device and never uploaded.",
                        isGranted: permissionManager.cameraPermissionStatus == .authorized
                    )
                    
                    PermissionRow(
                        icon: "photo.on.rectangle",
                        title: "Photo Library Access",
                        description: "Choose photos from your library to analyze. We only access photos you select.",
                        isGranted: permissionManager.photoLibraryPermissionStatus == .authorized
                    )
                }
                .padding(.horizontal, LayoutConstants.largePadding)
                
                Spacer()
                
                // Action Buttons
                VStack(spacing: LayoutConstants.padding) {
                    if !allPermissionsGranted {
                        Button(action: requestAllPermissions) {
                            Text("Grant Permissions")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: LayoutConstants.buttonHeight)
                                .background(Color.auraAccent)
                                .cornerRadius(LayoutConstants.cornerRadius)
                        }
                    } else {
                        Button(action: { coordinator.showModeSelection() }) {
                            Text("Continue")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: LayoutConstants.buttonHeight)
                                .background(Color.auraAccent)
                                .cornerRadius(LayoutConstants.cornerRadius)
                        }
                    }
                    
                    Button(action: { coordinator.showModeSelection() }) {
                        Text("Skip for Now")
                            .font(.subheadline)
                            .foregroundColor(.auraTextSecondary)
                    }
                }
                .padding(.horizontal, LayoutConstants.largePadding)
                .padding(.bottom, LayoutConstants.largePadding)
            }
        }
        .onAppear {
            permissionManager.checkPermissions()
        }
    }
    
    private var allPermissionsGranted: Bool {
        permissionManager.cameraPermissionStatus == .authorized &&
        permissionManager.photoLibraryPermissionStatus == .authorized
    }
    
    private func requestAllPermissions() {
        if permissionManager.cameraPermissionStatus != .authorized {
            permissionManager.requestCameraPermission { granted in
                if granted {
                    AnalyticsService.shared.logEvent(.cameraPermissionGranted)
                } else {
                    AnalyticsService.shared.logEvent(.cameraPermissionDenied)
                }
            }
        }
        
        if permissionManager.photoLibraryPermissionStatus != .authorized {
            permissionManager.requestPhotoLibraryPermission { granted in
                // Handle photo permission result
            }
        }
    }
}

// MARK: - Permission Row

struct PermissionRow: View {
    let icon: String
    let title: String
    let description: String
    let isGranted: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: LayoutConstants.padding) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(isGranted ? .green : .auraAccent)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    Spacer()
                    
                    if isGranted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    }
                }
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
}

