//
//  HistoryView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
#if canImport(Charts)
import Charts
#endif

struct HistoryView: View {
    
    @StateObject private var viewModel = HistoryViewModel()
    @StateObject private var coordinator: AppCoordinator
    @State private var showDeleteAlert = false
    @State private var selectedResult: AuraResult?
    @State private var selectedFavorite = false
    
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
                
                searchBar
                
                if viewModel.recentScanStats.count >= 2 {
                    trendCard
                }
                
                // Content
                if viewModel.isLoading {
                    loadingView
                } else if viewModel.filteredItems.isEmpty {
                    emptyStateViewContent
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
        .sheet(item: $selectedResult) { result in
            HistoryDetailView(
                result: result,
                isFavorite: $selectedFavorite,
                onDelete: {
                    viewModel.deleteItem(result)
                    selectedResult = nil
                },
                onToggleFavorite: {
                    viewModel.toggleFavorite(result)
                    selectedFavorite.toggle()
                }
            )
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
    
    private var trendCard: some View {
        ScanTrendCard(stats: viewModel.recentScanStats)
            .padding(.horizontal, LayoutConstants.padding)
            .padding(.bottom, LayoutConstants.padding)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.auraTextSecondary)
            TextField("Search aura colors or dates", text: $viewModel.searchText)
                .textInputAutocapitalization(.none)
                .disableAutocorrection(true)
                .foregroundColor(.auraText)
            
            if !viewModel.searchText.isEmpty {
                Button(action: { viewModel.searchText = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.auraTextSecondary)
                }
            }
        }
        .padding(.horizontal, LayoutConstants.padding)
        .padding(.vertical, 10)
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
        .padding(.horizontal, LayoutConstants.padding)
        .padding(.bottom, LayoutConstants.smallPadding)
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
    
    private var emptyStateViewContent: some View {
        Group {
            if !viewModel.searchText.isEmpty {
                EmptyStateView.searchEmpty()
            } else if viewModel.selectedFilter == .favorites {
                EmptyStateView.favoritesEmpty {
                    coordinator.showModeSelection()
                }
            } else {
                EmptyStateView.historyEmpty {
                    coordinator.showModeSelection()
                }
            }
        }
    }
    
    
    // MARK: - History List
    
    private var historyListView: some View {
        ScrollView {
            LazyVStack(spacing: LayoutConstants.padding) {
                ForEach(viewModel.filteredItems) { item in
                    HistoryRowView(
                        result: item,
                        isFavorite: viewModel.isFavorite(item),
                        onTap: {
                            selectedFavorite = viewModel.isFavorite(item)
                            selectedResult = item
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

// MARK: - Trend Card

struct ScanTrendCard: View {
    let stats: [HistoryViewModel.DailyScanStat]
    
    private var maxValue: CGFloat {
        CGFloat(stats.map { $0.count }.max() ?? 1)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Last \(stats.count) days")
                        .font(.caption)
                        .foregroundColor(.auraTextSecondary)
                    Text("Scan Trend")
                        .font(.headline)
                        .foregroundColor(.auraText)
                }
                Spacer()
                if let latest = stats.last?.count {
                    Text("\(latest) today")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.auraAccent)
                }
            }
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = width / CGFloat(max(stats.count - 1, 1))
                
                ZStack {
                    // Grid
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: height))
                        path.addLine(to: CGPoint(x: width, y: height))
                        path.move(to: CGPoint(x: 0, y: height / 2))
                        path.addLine(to: CGPoint(x: width, y: height / 2))
                    }
                    .stroke(Color.auraSurface, lineWidth: 1)
                    
                    // Area gradient
                    Path { path in
                        for (index, stat) in stats.enumerated() {
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(stat.count) / maxValue) * height
                            if index == 0 {
                                path.move(to: CGPoint(x: x, y: height))
                                path.addLine(to: CGPoint(x: x, y: y))
                            } else {
                                path.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                        if let last = stats.indices.last {
                            path.addLine(to: CGPoint(x: CGFloat(last) * stepX, y: height))
                            path.closeSubpath()
                        }
                    }
                    .fill(
                        LinearGradient(
                            colors: [Color.auraAccent.opacity(0.3), Color.auraAccent.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Line
                    Path { path in
                        for (index, stat) in stats.enumerated() {
                            let point = pointFor(stat: stat, index: index, width: width, height: height)
                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color.auraAccent, style: StrokeStyle(lineWidth: 2, lineJoin: .round))
                    
                    // Points
                    ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                        let point = pointFor(stat: stat, index: index, width: width, height: height)
                        Circle()
                            .fill(Color.white)
                            .frame(width: 8, height: 8)
                            .position(point)
                    }
                }
            }
            .frame(height: 140)
            
            HStack {
                ForEach(stats) { stat in
                    Text(stat.label.uppercased())
                        .font(.caption2)
                        .foregroundColor(.auraTextSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(LayoutConstants.padding)
        .background(Color.auraSurface)
        .cornerRadius(LayoutConstants.cornerRadius)
    }
    
    private func pointFor(stat: HistoryViewModel.DailyScanStat, index: Int, width: CGFloat, height: CGFloat) -> CGPoint {
        let stepX = width / CGFloat(max(stats.count - 1, 1))
        let x = CGFloat(index) * stepX
        let normalized = CGFloat(stat.count) / maxValue
        let y = height - (normalized * height)
        return CGPoint(x: x, y: y)
    }
}

// MARK: - Preview

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        HistoryView(coordinator: AppCoordinator())
    }
}

