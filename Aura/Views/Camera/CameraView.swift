//
//  CameraView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @StateObject private var viewModel: CameraViewModel
    @StateObject private var coordinator: AppCoordinator
    @State private var showImagePicker = false
    
    init(coordinator: AppCoordinator, viewModel: CameraViewModel = CameraViewModel()) {
        _coordinator = StateObject(wrappedValue: coordinator)
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack {
                // Header
                headerView
                
                Spacer()
                
                // Camera Preview or Permission Request
                if viewModel.permissionStatus == .authorized {
                    cameraContentView
                } else {
                    permissionRequestView
                }
                
                Spacer()
                
                // Bottom Controls
                bottomControlsView
            }
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $viewModel.capturedImage, onImagePicked: { image in
                if let image = image {
                    viewModel.processImage(image)
                }
            })
        }
        .onChange(of: viewModel.detectedAuraResult) { result in
            if let result = result {
                coordinator.showResult(result)
                viewModel.reset()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Text("Aura Scanner")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.auraText)
            
            Spacer()
            
            Button(action: { coordinator.showHistory() }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.title2)
                    .foregroundColor(.auraAccent)
            }
            
            Button(action: { coordinator.showSettings() }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(.auraAccent)
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
        .padding(.top, LayoutConstants.padding)
    }
    
    // MARK: - Camera Content
    
    private var cameraContentView: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            // Camera preview placeholder
            RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                .fill(Color.auraSurface)
                .frame(height: 400)
                .overlay(
                    VStack {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.auraTextSecondary)
                        
                        Text("Position your face in the center")
                            .font(.headline)
                            .foregroundColor(.auraTextSecondary)
                            .padding(.top)
                    }
                )
                .padding(.horizontal, LayoutConstants.padding)
            
            // Scan info
            if !viewModel.isProcessing {
                remainingScansView
            }
        }
    }
    
    // MARK: - Permission Request
    
    private var permissionRequestView: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.auraAccent)
            
            Text("Camera Access Required")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.auraText)
            
            Text("We need access to your camera to scan your aura")
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, LayoutConstants.largePadding)
            
            if viewModel.permissionStatus == .denied {
                Button(action: viewModel.openSettings) {
                    Text("Open Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutConstants.buttonHeight)
                        .background(Color.auraAccent)
                        .cornerRadius(LayoutConstants.cornerRadius)
                }
                .padding(.horizontal, LayoutConstants.largePadding)
            } else {
                Button(action: viewModel.requestCameraPermission) {
                    Text("Grant Access")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: LayoutConstants.buttonHeight)
                        .background(Color.auraAccent)
                        .cornerRadius(LayoutConstants.cornerRadius)
                }
                .padding(.horizontal, LayoutConstants.largePadding)
            }
        }
    }
    
    // MARK: - Remaining Scans
    
    private var remainingScansView: some View {
        let remainingScans = viewModel.getRemainingScans()
        
        return HStack {
            Image(systemName: remainingScans == Int.max ? "infinity" : "camera.fill")
                .foregroundColor(.auraAccent)
            
            Text(remainingScans == Int.max ? "Unlimited Scans" : "\(remainingScans) scans remaining today")
                .foregroundColor(.auraTextSecondary)
            
            if remainingScans != Int.max {
                Button(action: { coordinator.showPaywall() }) {
                    Text("Upgrade")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.auraAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.auraAccent.opacity(0.2))
                        .cornerRadius(LayoutConstants.smallCornerRadius)
                }
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControlsView: some View {
        HStack(spacing: LayoutConstants.largePadding) {
            // Gallery button
            Button(action: { showImagePicker = true }) {
                Image(systemName: "photo.on.rectangle")
                    .font(.title)
                    .foregroundColor(.auraAccent)
                    .frame(width: 60, height: 60)
                    .background(Color.auraSurface)
                    .clipShape(Circle())
            }
            
            // Capture button
            Button(action: handleCapture) {
                if viewModel.isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 80, height: 80)
                } else {
                    Circle()
                        .stroke(Color.auraAccent, lineWidth: 4)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .fill(Color.auraAccent)
                                .frame(width: 64, height: 64)
                        )
                }
            }
            .disabled(viewModel.isProcessing || !viewModel.canScanToday())
            
            // Info button
            Button(action: {}) {
                Image(systemName: "info.circle")
                    .font(.title)
                    .foregroundColor(.auraAccent)
                    .frame(width: 60, height: 60)
                    .background(Color.auraSurface)
                    .clipShape(Circle())
            }
        }
        .padding(.bottom, LayoutConstants.largePadding)
    }
    
    // MARK: - Actions
    
    private func handleCapture() {
        guard viewModel.canScanToday() else {
            coordinator.showPaywall()
            return
        }
        
        viewModel.incrementDailyCount()
        
        // Simulate capture (in real implementation, this would capture from camera)
        // For now, open image picker
        showImagePicker = true
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage?
    var onImagePicked: (UIImage?) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
                parent.onImagePicked(image)
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(coordinator: AppCoordinator())
    }
}

