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
    let mode: AuraMode?
    
    init(result: AuraResult, coordinator: AppCoordinator, mode: AuraMode? = nil) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(auraResult: result))
        _coordinator = StateObject(wrappedValue: coordinator)
        self.mode = mode
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
                    
                    // Combined Aura Composition
                    combinedAuraView
                    
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
            Button(action: { 
                coordinator.showCamera()
            }) {
                Image(systemName: "xmark")
                    .font(.title2)
                    .foregroundColor(.auraText)
            }
            
            Spacer()
            
            Text(resultTitle)
                .font(.title2.bold())
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
    
    private var resultTitle: String {
        let language = Locale.current.languageCode ?? "en"
        if language.hasPrefix("tr") {
            return mode?.resultTitleTR ?? "Auranız"
        } else {
            return mode?.resultTitle ?? "Your Aura"
        }
    }
    
    // MARK: - Aura Rings
    
    private var auraRingsView: some View {
        AuraRingsView(
            auraColors: viewModel.auraResult.dominantColors,
            dominancePercentages: viewModel.auraResult.dominancePercentages
        )
        .padding(.vertical, LayoutConstants.padding)
    }
    
    // MARK: - Combined Aura View
    
    private var combinedAuraView: some View {
        VStack(spacing: LayoutConstants.padding) {
            Text("Your Aura Composition")
                .font(.headline)
                .foregroundColor(.auraText)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Primary Color
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(viewModel.auraResult.primaryColor.color)
                        .frame(width: 30, height: 30)
                    Text(viewModel.auraResult.primaryColor.name + " Aura")
                        .font(.title3.bold())
                        .foregroundColor(.auraText)
                    Spacer()
                    if !viewModel.auraResult.dominancePercentages.isEmpty {
                        Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[0]))
                            .font(.title3.bold())
                            .foregroundColor(.auraAccent)
                    }
                }
                
                Text(viewModel.showFullDescription ? viewModel.primaryStory : viewModel.primaryDescription)
                    .font(.body)
                    .foregroundColor(.auraTextSecondary)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding()
            .background(Color.auraSurface)
            .cornerRadius(LayoutConstants.cornerRadius)
            
            // Secondary Color
            if let secondaryColor = viewModel.auraResult.secondaryColor,
               let secondaryDesc = viewModel.secondaryDescription {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(secondaryColor.color)
                            .frame(width: 30, height: 30)
                        Text(secondaryColor.name + " Energy")
                            .font(.headline)
                            .foregroundColor(.auraText)
                        Spacer()
                        if viewModel.auraResult.dominancePercentages.count > 1 {
                            Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[1]))
                                .font(.headline.bold())
                                .foregroundColor(.auraAccent)
                        }
                    }
                    
                    Text(secondaryDesc)
                        .font(.subheadline)
                        .foregroundColor(.auraTextSecondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.auraSurface)
                .cornerRadius(LayoutConstants.cornerRadius)
            }
            
            // Tertiary Color
            if let tertiaryColor = viewModel.auraResult.tertiaryColor,
               let tertiaryDesc = viewModel.tertiaryDescription {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(tertiaryColor.color)
                            .frame(width: 30, height: 30)
                        Text(tertiaryColor.name + " Influence")
                            .font(.headline)
                            .foregroundColor(.auraText)
                        Spacer()
                        if viewModel.auraResult.dominancePercentages.count > 2 {
                            Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[2]))
                                .font(.headline.bold())
                                .foregroundColor(.auraAccent)
                        }
                    }
                    
                    Text(tertiaryDesc)
                        .font(.subheadline)
                        .foregroundColor(.auraTextSecondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(Color.auraSurface)
                .cornerRadius(LayoutConstants.cornerRadius)
            }
            
            // Toggle Button
            if viewModel.canViewFullDescription {
                Button(action: { viewModel.toggleFullDescription() }) {
                    HStack {
                        Image(systemName: viewModel.showFullDescription ? "chevron.up" : "chevron.down")
                        Text(viewModel.showFullDescription ? "Show Summary" : "Read Full Description")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.auraAccent)
                    .padding(.vertical, 8)
                }
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    // MARK: - Old Color Breakdown (Deprecated)
    
    private var colorBreakdownView_OLD: some View {
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
                            .font(.body.weight(.semibold))
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
    
    // MARK: - Old Description (Deprecated)
    
    private var descriptionView_OLD: some View {
        VStack(alignment: .leading, spacing: LayoutConstants.padding) {
            // Primary color interpretation
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(viewModel.auraResult.primaryColor.color)
                        .frame(width: 24, height: 24)
                    Text(viewModel.auraResult.primaryColor.name + " Aura")
                        .font(.title3.bold())
                        .foregroundColor(.auraText)
                }
                
                // Story/Narrative (always shown)
                Text(viewModel.showFullDescription ? viewModel.primaryStory : viewModel.primaryDescription)
                    .font(.body)
                    .foregroundColor(.auraTextSecondary)
                    .lineSpacing(8)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Secondary color interpretation (if exists)
            if let secondaryColor = viewModel.auraResult.secondaryColor,
               let secondaryDesc = viewModel.secondaryDescription {
                Divider()
                    .background(Color.auraTextSecondary.opacity(0.3))
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(secondaryColor.color)
                            .frame(width: 20, height: 20)
                        Text(secondaryColor.name + " Energy")
                            .font(.subheadline)
                            .foregroundColor(.auraText)
                    }
                    
                    Text(secondaryDesc)
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                        .lineSpacing(4)
                }
            }
            
            // Tertiary color interpretation (if exists)
            if let tertiaryColor = viewModel.auraResult.tertiaryColor,
               let tertiaryDesc = viewModel.tertiaryDescription {
                Divider()
                    .background(Color.auraTextSecondary.opacity(0.3))
                    .padding(.vertical, 4)
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Circle()
                            .fill(tertiaryColor.color)
                            .frame(width: 20, height: 20)
                        Text(tertiaryColor.name + " Influence")
                            .font(.caption)
                            .foregroundColor(.auraText)
                    }
                    
                    Text(tertiaryDesc)
                        .font(.caption2)
                        .foregroundColor(.auraTextSecondary)
                        .lineSpacing(3)
                }
            }
            
            // Toggle full description button
            Button(action: viewModel.toggleFullDescription) {
                HStack {
                    Text(viewModel.showFullDescription ? "Show less" : "Read full description")
                        .font(.subheadline)
                    Image(systemName: viewModel.showFullDescription ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.auraAccent)
            }
            .padding(.top, LayoutConstants.smallPadding)
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
        ResultView(result: AuraResult.preview, coordinator: AppCoordinator(), mode: .faceDetection)
    }
}

