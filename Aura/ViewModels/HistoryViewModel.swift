//
//  HistoryViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import Combine

/// ViewModel for managing scan history
class HistoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var historyItems: [AuraResult] = []
    @Published var favoriteItems: [AuraResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedFilter: FilterType = .all
    
    // MARK: - Filter Types
    
    enum FilterType: String, CaseIterable {
        case all = "All"
        case favorites = "Favorites"
        
        var icon: String {
            switch self {
            case .all: return "list.bullet"
            case .favorites: return "star.fill"
            }
        }
    }
    
    // MARK: - Dependencies
    
    private let dataManager: DataManager
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var displayedItems: [AuraResult] {
        switch selectedFilter {
        case .all:
            return historyItems
        case .favorites:
            return favoriteItems
        }
    }
    
    var hasHistory: Bool {
        !historyItems.isEmpty
    }
    
    var totalScans: Int {
        historyItems.count
    }
    
    // Statistics
    var mostFrequentColor: AuraColor? {
        let colorCounts = Dictionary(grouping: historyItems, by: { $0.primaryColor.id })
        let mostFrequent = colorCounts.max(by: { $0.value.count < $1.value.count })
        guard let colorId = mostFrequent?.key else { return nil }
        return AuraColor.allColors.first(where: { $0.id == colorId })
    }
    
    // MARK: - Initialization
    
    init(dataManager: DataManager = .shared) {
        self.dataManager = dataManager
        loadHistory()
        setupNotificationObservers()
    }
    
    // MARK: - Setup
    
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .didCompleteScan)
            .sink { [weak self] _ in
                self?.loadHistory()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Data Loading
    
    func loadHistory() {
        isLoading = true
        
        do {
            historyItems = try dataManager.fetchAllHistory()
            favoriteItems = try dataManager.fetchFavorites()
            isLoading = false
            
            logEvent(.historyViewed, parameters: [
                "total_scans": totalScans
            ])
        } catch {
            errorMessage = "Failed to load history: \(error.localizedDescription)"
            showError = true
            isLoading = false
        }
    }
    
    func refresh() {
        loadHistory()
    }
    
    // MARK: - Actions
    
    func deleteItem(_ result: AuraResult) {
        do {
            try dataManager.deleteHistory(result)
            loadHistory()
        } catch {
            errorMessage = "Failed to delete item: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func toggleFavorite(_ result: AuraResult) {
        do {
            try dataManager.toggleFavorite(result)
            loadHistory()
        } catch {
            errorMessage = "Failed to update favorite: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func deleteAll() {
        do {
            try dataManager.deleteAllHistory()
            loadHistory()
        } catch {
            errorMessage = "Failed to delete all history: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func isFavorite(_ result: AuraResult) -> Bool {
        favoriteItems.contains(where: { $0.id == result.id })
    }
    
    // MARK: - Filtering
    
    func setFilter(_ filter: FilterType) {
        selectedFilter = filter
    }
    
    // MARK: - Search
    
    func search(by colorName: String) -> [AuraResult] {
        guard !colorName.isEmpty else { return historyItems }
        return historyItems.filter { 
            $0.primaryColor.name.localizedCaseInsensitiveContains(colorName)
        }
    }
    
    func filterByDateRange(from startDate: Date, to endDate: Date) -> [AuraResult] {
        return historyItems.filter { result in
            result.timestamp >= startDate && result.timestamp <= endDate
        }
    }
    
    // MARK: - Statistics
    
    func getColorDistribution() -> [AuraColor: Int] {
        var distribution: [AuraColor: Int] = [:]
        
        for item in historyItems {
            distribution[item.primaryColor, default: 0] += 1
        }
        
        return distribution
    }
    
    func getAverageScansPerDay() -> Double {
        guard !historyItems.isEmpty else { return 0 }
        
        let oldestDate = historyItems.last?.timestamp ?? Date()
        let newestDate = historyItems.first?.timestamp ?? Date()
        let daysDifference = Calendar.current.dateComponents([.day], from: oldestDate, to: newestDate).day ?? 1
        
        return Double(historyItems.count) / Double(max(daysDifference, 1))
    }
    
    // MARK: - Analytics
    
    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        print("Analytics Event: \(event.rawValue), parameters: \(parameters)")
    }
}

