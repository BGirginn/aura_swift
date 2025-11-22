//
//  CameraView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    
    @StateObject private var viewModel = CameraViewModel()
    @StateObject private var coordinator: AppCoordinator
    @State private var showImagePicker = false
    let mode: AuraMode
    
    init(coordinator: AppCoordinator, mode: AuraMode) {
        _coordinator = StateObject(wrappedValue: coordinator)
        self.mode = mode
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
            ImagePicker(onImagePicked: handleGalleryPick)
        }
        .onChange(of: viewModel.detectedAuraResult) { result in
            if let result = result {
                coordinator.showResult(result, mode: mode)
                viewModel.reset()
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { coordinator.showModeSelection() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.auraText)
            }
            
            VStack(alignment: .leading) {
                Text(modeTitle)
                    .font(.headline.bold())
                    .foregroundColor(.auraText)
                Text(modeSubtitle)
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
            }
            
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
    
    private var modeTitle: String {
        let language = Locale.current.languageCode ?? "en"
        return language.hasPrefix("tr") ? mode.displayNameTR : mode.displayName
    }
    
    private var modeSubtitle: String {
        switch mode {
        case .faceAura:
            return "Position your face in center"
        case .outfitAura:
            return "Capture your outfit or environment"
        }
    }
    
    // MARK: - Camera Content
    
    private var cameraContentView: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            // Real Camera preview
            CameraPreviewView(session: viewModel.cameraService.session)
                .frame(height: 500)
                .cornerRadius(LayoutConstants.cornerRadius)
                .overlay(
                    VStack {
                        Spacer()
                        Text(mode == .faceAura ? "Position your face in the center" : "Capture your outfit or environment")
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(8)
                            .padding(.bottom, 8)
                    }
                )
                .padding(.horizontal, LayoutConstants.padding)
            
            // Scan info or processing indicator
            if viewModel.isProcessing {
                processingIndicatorView
            } else {
                remainingScansView
            }
        }
        .onAppear {
            viewModel.startCamera()
        }
        .onDisappear {
            viewModel.stopCamera()
        }
    }
    
    // MARK: - Permission Request
    
    private var permissionRequestView: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Image(systemName: "camera.fill")
                .font(.system(size: 80))
                .foregroundColor(.auraAccent)
            
            Text("Camera Access Required")
                .font(.title2.bold())
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
        let remaining = viewModel.getRemainingScans()
        let isPremium = SubscriptionManager.shared.isPremium
        
        return HStack {
            if isPremium {
                Image(systemName: "infinity")
                    .foregroundColor(.auraAccent)
                Text("Unlimited Scans")
                    .foregroundColor(.auraTextSecondary)
            } else {
                Image(systemName: "camera.fill")
                    .foregroundColor(.auraAccent)
                Text("\(remaining) scans remaining today")
                    .foregroundColor(.auraTextSecondary)
            }
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Processing Indicator
    
    private var processingIndicatorView: some View {
        ProcessingIndicatorView(
            currentStep: ProcessingIndicatorView.ProcessingStep.detecting,
            progress: 0.5
        )
    }
    
    // MARK: - Bottom Controls
    
    private var bottomControlsView: some View {
        VStack(spacing: LayoutConstants.padding) {
            // Debug test buttons (if debug mode enabled)
            #if DEBUG
            if DebugManager.shared.isDebugMode {
                debugTestButtonsView
            }
            #endif
            
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
                
                // Capture button (from camera)
                Button(action: handleCameraCapture) {
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
                .disabled(viewModel.isProcessing)
                
                // Flip camera button
                Button(action: {}) {
                    Image(systemName: "camera.rotate")
                        .font(.title)
                        .foregroundColor(.auraAccent)
                        .frame(width: 60, height: 60)
                        .background(Color.auraSurface)
                        .clipShape(Circle())
                }
            }
        }
        .padding(.bottom, LayoutConstants.largePadding)
    }
    
    // MARK: - Debug Test Buttons
    
    private var debugTestButtonsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(DebugManager.shared.getAllTestColors(), id: \.color.id) { item in
                    Button(action: {
                        let testResult = DebugManager.shared.generateSampleResult(colorType: item.color)
                        coordinator.showResult(testResult)
                    }) {
                        Text(item.name)
                            .font(.caption)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(item.color.color)
                            .cornerRadius(12)
                    }
                }
            }
            .padding(.horizontal, LayoutConstants.padding)
        }
    }
    
    // MARK: - Actions
    
    private func handleCameraCapture() {
        // Capture from camera
        HapticManager.shared.scanStarted()
        viewModel.capturePhoto()
    }
    
    private func handleGalleryPick(_ image: UIImage?) {
        guard let image = image else { return }
        HapticManager.shared.scanStarted()
        viewModel.processImage(image, mode: mode)
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
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
            parent.presentationMode.wrappedValue.dismiss()
            
            if let image = info[.originalImage] as? UIImage {
                print("✅ Image picked: \(image.size)")
                DispatchQueue.main.async {
                    self.parent.onImagePicked(image)
                }
            }
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - Preview

struct CameraView_Previews: PreviewProvider {
    static var previews: some View {
        CameraView(coordinator: AppCoordinator(), mode: .faceAura)
    }
}

