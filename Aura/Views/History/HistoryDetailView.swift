//
//  HistoryDetailView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct HistoryDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    @Binding var isFavorite: Bool
    @StateObject private var viewModel: ResultViewModel
    @State private var showShareSheet = false
    @State private var shareItems: [Any] = []
    let onDelete: () -> Void
    let onToggleFavorite: () -> Void
    
    init(result: AuraResult,
         isFavorite: Binding<Bool>,
         onDelete: @escaping () -> Void,
         onToggleFavorite: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ResultViewModel(auraResult: result))
        _isFavorite = isFavorite
        self.onDelete = onDelete
        self.onToggleFavorite = onToggleFavorite
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: LayoutConstants.largePadding) {
                    headerInfo
                    if let preview = viewModel.auraResult.image {
                        photoPreview(preview)
                    }
                    AuraRingsView(
                        auraColors: viewModel.auraResult.dominantColors,
                        dominancePercentages: viewModel.auraResult.dominancePercentages
                    )
                    .padding(.horizontal, LayoutConstants.padding)
                    
                    dominanceList
                    descriptionCards
                }
                .padding(.bottom, LayoutConstants.largePadding)
            }
            .background(Color.auraBackground.ignoresSafeArea())
            .navigationTitle("Scan Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                        .foregroundColor(.auraAccent)
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: handleFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .auraText)
                    }
                    Button(action: handleShare) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.auraText)
                    }
                    Button(role: .destructive, action: handleDelete) {
                        Image(systemName: "trash")
                    }
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheet(items: shareItems)
        }
    }
    
    private var headerInfo: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.auraResult.primaryColor.name + " Aura")
                .font(.largeTitle.bold())
                .foregroundColor(.auraText)
            
            Text(viewModel.auraResult.formattedDate)
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
            
            HStack(spacing: 12) {
                Label(viewModel.auraResult.countryCode.uppercased(), systemImage: "globe")
                    .font(.caption)
                    .foregroundColor(.auraTextSecondary)
                if let secondary = viewModel.auraResult.secondaryColor {
                    Label("with \(secondary.name)", systemImage: "sparkles")
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                }
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    private func photoPreview(_ image: UIImage) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(height: 220)
            .clipped()
            .cornerRadius(LayoutConstants.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                    .stroke(Color.auraSurface, lineWidth: 1)
            )
            .padding(.horizontal, LayoutConstants.padding)
    }
    
    private var dominanceList: some View {
        VStack(spacing: LayoutConstants.smallPadding) {
            ForEach(Array(viewModel.auraResult.dominantColors.enumerated()), id: \.offset) { index, color in
                HStack {
                    Circle()
                        .fill(color.color)
                        .frame(width: 18, height: 18)
                    Text(color.name)
                        .font(.subheadline)
                        .foregroundColor(.auraText)
                    Spacer()
                    if index < viewModel.auraResult.dominancePercentages.count {
                        Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[index]))
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.auraAccent)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.auraSurface.opacity(0.8))
                .cornerRadius(LayoutConstants.cornerRadius)
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    private var descriptionCards: some View {
        VStack(spacing: LayoutConstants.padding) {
            colorDescriptionCard(
                title: "\(viewModel.auraResult.primaryColor.name) Aura",
                color: viewModel.auraResult.primaryColor.color,
                percentageIndex: 0,
                text: viewModel.showFullDescription ? viewModel.primaryStory : viewModel.primaryDescription
            )
            
            if let secondary = viewModel.auraResult.secondaryColor,
               let desc = viewModel.secondaryDescription {
                colorDescriptionCard(
                    title: "\(secondary.name) Energy",
                    color: secondary.color,
                    percentageIndex: 1,
                    text: desc
                )
            }
            
            if let tertiary = viewModel.auraResult.tertiaryColor,
               let desc = viewModel.tertiaryDescription {
                colorDescriptionCard(
                    title: "\(tertiary.name) Influence",
                    color: tertiary.color,
                    percentageIndex: 2,
                    text: desc
                )
            }
            
            if viewModel.canViewFullDescription {
                Button(action: viewModel.toggleFullDescription) {
                    Label(
                        viewModel.showFullDescription ? "Show Summary" : "Read Full Story",
                        systemImage: viewModel.showFullDescription ? "chevron.up" : "chevron.down"
                    )
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.auraAccent)
                }
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
    }
    
    private func colorDescriptionCard(title: String, color: Color, percentageIndex: Int, text: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 26, height: 26)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.auraText)
                Spacer()
                if percentageIndex < viewModel.auraResult.dominancePercentages.count {
                    Text(String(format: "%.0f%%", viewModel.auraResult.dominancePercentages[percentageIndex]))
                        .font(.headline.bold())
                        .foregroundColor(.auraAccent)
                }
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .lineSpacing(4)
        }
        .padding()
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    private func handleFavorite() {
        isFavorite.toggle()
        onToggleFavorite()
    }
    
    private func handleShare() {
        let image = viewModel.shareResult() ?? ShareCardGenerator.shared.generateCard(for: viewModel.auraResult)
        guard let shareImage = image else { return }
        shareItems = [shareImage]
        showShareSheet = true
    }
    
    private func handleDelete() {
        onDelete()
        dismiss()
    }
}


