//
//  ResultView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct ResultView: View {
    
    @StateObject private var viewModel: ResultViewModel
    @StateObject private var coordinator: AppCoordinator
    @State private var showShareSheet = false
    @State private var shareImage: UIImage?
    
    init(result: AuraResult, coordinator: AppCoordinator) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(auraResult: result))
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    // Header
                    headerView
                    
                    // Aura Ring Visualization
                    auraRingsView
                    
                    // Color Breakdown
                    colorBreakdownView
                    
                    // Description
                    descriptionView
                    
                    // Action Buttons
                    actionButtonsView
                    
                    // Bottom spacing
                    Spacer(minLength: LayoutConstants.largePadding)
                }
                .padding(.vertical, LayoutConstants.padding)
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let shareImage = shareImage {
                ShareSheet(items: [shareImage])
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { coordinator.showCamera() }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.auraText)
            }
            
            Spacer()
            
            Text("Your Aura")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.auraText)
            
            Spacer()
            
            Button(action: handleShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.title2)
                    .foregroundColor(.auraText)
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Aura Rings
    
    private var auraRingsView: some View {
        ZStack {
            // Background glow
            ForEach(viewModel.auraResult.dominantColors.indices, id: \.self) { index in
                let color = viewModel.auraResult.dominantColors[index]
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [color.color.opacity(0.3), Color.clear],
                            center: .center,
                            startRadius: 50,
                            endRadius: 150 + CGFloat(index * 30)
                        )
                    )
                    .frame(width: 300 + CGFloat(index * 60), height: 300 + CGFloat(index * 60))
                    .blur(radius: 20)
            }
            
            // Rings
            ForEach(viewModel.auraResult.dominantColors.indices, id: \.self) { index in
                let color = viewModel.auraResult.dominantColors[index]
                Circle()
                    .stroke(color.color, lineWidth: AuraRingConstants.ringWidth)
                    .frame(width: 200 + CGFloat(index * 60), height: 200 + CGFloat(index * 60))
                    .shadow(color: color.color.opacity(0.5), radius: 10)
            }
            
            // Center icon
            Image(systemName: "sparkles")
                .font(.system(size: 40))
                .foregroundColor(.white)
        }
        .frame(height: 400)
        .padding(.vertical, LayoutConstants.padding)
    }
    
    // MARK: - Color Breakdown
    
    private var colorBreakdownView: some View {
        VStack(spacing: LayoutConstants.padding) {
            Text("Color Composition")
                .font(.headline)
                .foregroundColor(.auraText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(Array(viewModel.auraResult.dominantColors.enumerated()), id: \.offset) { index, color in
                HStack {
                    // Color indicator
                    Circle()
                        .fill(color.color)
                        .frame(width: 30, height: 30)
                    
                    // Color name
                    Text(color.name)
                        .font(.body)
                        .foregroundColor(.auraText)
                    
                    Spacer()
                    
                    // Percentage
                    if index < viewModel.auraResult.dominancePercentages.count {
                        Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[index]))
                            .font(.body)
                            .fontWeight(.semibold)
                            .foregroundColor(.auraAccent)
                    }
                }
                .padding()
                .background(Color.auraSurface)
                .cornerRadius(LayoutConstants.cornerRadius)
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Description
    
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            Text("Interpretation")
                .font(.headline)
                .foregroundColor(.auraText)
            
            Text(viewModel.primaryDescription)
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .lineSpacing(6)
            
            if !viewModel.showFullDescription && !viewModel.canViewFullDescription {
                Button(action: viewModel.toggleFullDescription) {
                    HStack {
                        Text("Read full description")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Image(systemName: "crown.fill")
                            .font(.caption)
                    }
                    .foregroundColor(.auraAccent)
                }
                .padding(.top, LayoutConstants.smallPadding)
            }
        }
        .padding(LayoutConstants.padding)
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtonsView: some View {
        VStack(spacing: LayoutConstants.padding) {
            // Save button
            Button(action: viewModel.saveResult) {
                HStack {
                    Image(systemName: viewModel.isSaved ? "checkmark.circle.fill" : "square.and.arrow.down")
                    Text(viewModel.isSaved ? "Saved" : "Save to History")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: LayoutConstants.buttonHeight)
                .background(viewModel.isSaved ? Color.green : Color.auraAccent)
                .cornerRadius(LayoutConstants.cornerRadius)
            }
            .disabled(viewModel.isSaving || viewModel.isSaved)
            
            // Scan again button
            Button(action: { coordinator.showCamera() }) {
                Text("Scan Again")
                    .font(.headline)
                    .foregroundColor(.auraAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: LayoutConstants.buttonHeight)
                    .background(Color.auraSurface)
                    .cornerRadius(LayoutConstants.cornerRadius)
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Actions
    
    private func handleShare() {
        shareImage = viewModel.shareResult()
        showShareSheet = true
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Preview

struct ResultView_Previews: PreviewProvider {
    static var previews: some View {
        ResultView(result: AuraResult.preview, coordinator: AppCoordinator())
    }
}

