//
//  HistoryViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import Combine

/// ViewModel for managing scan history
@MainActor
class HistoryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var historyItems: [AuraResult] = []
    @Published var favoriteItems: [AuraResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var selectedFilter: FilterType = .all
    @Published var searchText: String = ""
    
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
    
    struct DailyScanStat: Identifiable {
        let date: Date
        let count: Int
        
        var id: Date { date }
        
        var label: String {
            return Self.formatter.string(from: date)
        }
        
        private static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter
        }()
    }
    
    // MARK: - Computed Properties
    
    private var filteredBySelection: [AuraResult] {
        switch selectedFilter {
        case .all:
            return historyItems
        case .favorites:
            return favoriteItems
        }
    }
    
    var filteredItems: [AuraResult] {
        let base = filteredBySelection
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return base }
        let term = searchText.lowercased()
        return base.filter { result in
            var fields: [String] = [result.primaryColor.name]
            if let secondary = result.secondaryColor {
                fields.append(secondary.name)
            }
            if let tertiary = result.tertiaryColor {
                fields.append(tertiary.name)
            }
            fields.append(result.formattedDate)
            return fields.contains { $0.lowercased().contains(term) }
        }
    }
    
    var recentScanStats: [DailyScanStat] {
        guard !historyItems.isEmpty else { return [] }
        let calendar = Calendar.current
        
        let grouped = Dictionary(grouping: historyItems) { calendar.startOfDay(for: $0.timestamp) }
        let sortedDates = grouped.keys.sorted()
        
        let stats = sortedDates.map { date -> DailyScanStat in
            DailyScanStat(date: date, count: grouped[date]?.count ?? 0)
        }
        
        return Array(stats.suffix(7))
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
        AnalyticsService.shared.logEvent(event, parameters: parameters)
    }
}

