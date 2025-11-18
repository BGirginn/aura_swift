//
//  HistoryView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var coordinator: AppCoordinator
    @State private var showDeleteAlert = false
    
    init(coordinator: AppCoordinator) {
        _coordinator = StateObject(wrappedValue: coordinator)
    }
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                headerView
                
                // Filter
                filterView
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.displayedItems.isEmpty {
                    emptyStateView
                } else {
                    historyListView
                }
            }
        }
        .alert("Delete All History", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteAll()
            }
        } message: {
            Text("Are you sure you want to delete all scan history? This action cannot be undone.")
        }
        .alert("Error", isPresented: $viewModel.showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        HStack {
            Button(action: { coordinator.showCamera() }) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.auraText)
            }
            
            Text("Scan History")
                .font(.title.bold())
                .foregroundColor(.auraText)
            
            Spacer()
            
            if viewModel.hasHistory {
                Button(action: { showDeleteAlert = true }) {
                    Image(systemName: "trash")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(LayoutConstants.padding)
    }
    
    // MARK: - Filter
    
    private var filterView: some View {
        HStack(spacing: LayoutConstants.padding) {
            ForEach(HistoryViewModel.FilterType.allCases, id: \.self) { filter in
                Button(action: { viewModel.setFilter(filter) }) {
                    HStack {
                        Image(systemName: filter.icon)
                        Text(filter.rawValue)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(viewModel.selectedFilter == filter ? .white : .auraTextSecondary)
                    .padding(.horizontal, LayoutConstants.padding)
                    .padding(.vertical, LayoutConstants.smallPadding)
                    .background(viewModel.selectedFilter == filter ? Color.auraAccent : Color.auraSurface)
                    .cornerRadius(LayoutConstants.cornerRadius)
                }
            }
            
            Spacer()
            
            // Stats
            Text("\(viewModel.totalScans) scans")
                .font(.caption)
                .foregroundColor(.auraTextSecondary)
        }
        .padding(.horizontal, LayoutConstants.padding)
        .padding(.bottom, LayoutConstants.padding)
    }
    
    // MARK: - Loading
    
    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .auraAccent))
            Text("Loading history...")
                .font(.subheadline)
                .foregroundColor(.auraTextSecondary)
                .padding(.top)
            Spacer()
        }
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: LayoutConstants.largePadding) {
            Spacer()
            
            Image(systemName: viewModel.selectedFilter == .favorites ? "star" : "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundColor(.auraTextSecondary)
            
            Text(viewModel.selectedFilter == .favorites ? "No Favorites Yet" : "No Scans Yet")
                .font(.title2.bold())
                .foregroundColor(.auraText)
            
            Text(viewModel.selectedFilter == .favorites ? "Mark scans as favorite to see them here" : "Your scan history will appear here")
                .font(.body)
                .foregroundColor(.auraTextSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: { coordinator.showCamera() }) {
                Text("Start Scanning")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, LayoutConstants.largePadding)
                    .padding(.vertical, LayoutConstants.padding)
                    .background(Color.auraAccent)
                    .cornerRadius(LayoutConstants.cornerRadius)
            }
            .padding(.top)
            
            Spacer()
        }
        .padding(LayoutConstants.largePadding)
    }
    
    // MARK: - History List
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: LayoutConstants.padding) {
                ForEach(viewModel.displayedItems) { item in
                    HistoryRowView(
                        result: item,
                        isFavorite: viewModel.isFavorite(item),
                        onTap: {
                            coordinator.showResult(item)
                        },
                        onFavorite: {
                            viewModel.toggleFavorite(item)
                        },
                        onDelete: {
                            viewModel.deleteItem(item)
                        }
                    )
                }
            }
            .padding(LayoutConstants.padding)
        }
    }
}

// MARK: - History Row

struct HistoryRowView: View {
    let result: AuraResult
    let isFavorite: Bool
    let onTap: () -> Void
    let onFavorite: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: LayoutConstants.padding) {
                // Aura color preview
                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [result.primaryColor.color, result.primaryColor.color.opacity(0.3)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                    
                    if let secondaryColor = result.secondaryColor {
                        Circle()
                            .stroke(secondaryColor.color, lineWidth: 3)
                            .frame(width: 60, height: 60)
                    }
                }
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.primaryColor.name)
                        .font(.headline)
                        .foregroundColor(.auraText)
                    
                    if let secondaryColor = result.secondaryColor {
                        Text("with \(secondaryColor.name)")
                            .font(.subheadline)
                            .foregroundColor(.auraTextSecondary)
                    }
                    
                    Text(result.formattedDate)
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                }
                
                Spacer()
                
                // Actions
                HStack(spacing: LayoutConstants.smallPadding) {
                    Button(action: onFavorite) {
                        Image(systemName: isFavorite ? "star.fill" : "star")
                            .foregroundColor(isFavorite ? .yellow : .auraTextSecondary)
                    }
                    
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            .padding(LayoutConstants.padding)
            .background(Color.auraSurface)
            .cornerRadius(LayoutConstants.cornerRadius)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(coordinator: AppCoordinator())
    }
}

