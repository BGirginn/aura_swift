//
//  ResultViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import Combine

/// ViewModel for displaying aura scan results
class ResultViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var auraResult: AuraResult
    @Published var showFullDescription = false
    @Published var isSaving = false
    @Published var isSaved = false
    @Published var isSharing = false
    
    // MARK: - Dependencies
    
    private let localizationService: LocalizationService
    private let dataManager: DataManager
    
    // MARK: - Computed Properties
    
    var primaryDescription: String {
        if showFullDescription {
            return localizationService.getLongDescription(
                for: auraResult.primaryColor,
                countryCode: auraResult.countryCode
            )
        } else {
            return localizationService.getShortDescription(
                for: auraResult.primaryColor,
                countryCode: auraResult.countryCode
            )
        }
    }
    
    var secondaryDescription: String? {
        guard let secondaryColor = auraResult.secondaryColor else { return nil }
        return localizationService.getShortDescription(
            for: secondaryColor,
            countryCode: auraResult.countryCode
        )
    }
    
    var tertiaryDescription: String? {
        guard let tertiaryColor = auraResult.tertiaryColor else { return nil }
        return localizationService.getShortDescription(
            for: tertiaryColor,
            countryCode: auraResult.countryCode
        )
    }
    
    var canViewFullDescription: Bool {
        UserDefaults.standard.bool(forKey: UserDefaultsKeys.isPremiumUser)
    }
    
    // MARK: - Initialization
    
    init(auraResult: AuraResult,
         localizationService: LocalizationService = .shared,
         dataManager: DataManager = .shared) {
        self.auraResult = auraResult
        self.localizationService = localizationService
        self.dataManager = dataManager
    }
    
    // MARK: - Actions
    
    func toggleFullDescription() {
        if canViewFullDescription {
            showFullDescription.toggle()
        } else {
            // Show paywall
            NotificationCenter.default.post(name: Notification.Name("showPaywall"), object: nil)
        }
    }
    
    func saveResult() {
        isSaving = true
        
        do {
            try dataManager.saveAuraResult(auraResult)
            isSaved = true
            logEvent(.resultSaved)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.isSaving = false
            }
        } catch {
            print("Failed to save result: \(error.localizedDescription)")
            isSaving = false
        }
    }
    
    func shareResult() -> UIImage? {
        // Generate a shareable image with the aura result
        isSharing = true
        defer { isSharing = false }
        
        logEvent(.resultShared, parameters: [
            "primary_color": auraResult.primaryColor.id
        ])
        
        // Return the captured image or generate a card
        return auraResult.image ?? generateShareCard()
    }
    
    private func generateShareCard() -> UIImage? {
        // Create a shareable card with aura colors and basic info
        let size = CGSize(width: 1080, height: 1920)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        
        return renderer.image { context in
            // Background
            UIColor(Color.auraBackground).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Title
            let titleText = "My Aura"
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 72, weight: .bold),
                .foregroundColor: UIColor.white
            ]
            let titleSize = titleText.size(withAttributes: titleAttributes)
            titleText.draw(at: CGPoint(x: (size.width - titleSize.width) / 2, y: 200), withAttributes: titleAttributes)
            
            // Primary color circle
            let circleDiameter: CGFloat = 400
            let circleRect = CGRect(
                x: (size.width - circleDiameter) / 2,
                y: 500,
                width: circleDiameter,
                height: circleDiameter
            )
            
            UIColor(auraResult.primaryColor.color).setFill()
            context.cgContext.fillEllipse(in: circleRect)
            
            // Color name
            let colorName = auraResult.primaryColor.name
            let nameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 60, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let nameSize = colorName.size(withAttributes: nameAttributes)
            colorName.draw(at: CGPoint(x: (size.width - nameSize.width) / 2, y: 1000), withAttributes: nameAttributes)
            
            // App name
            let appName = AppConstants.appName
            let appNameAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 48, weight: .light),
                .foregroundColor: UIColor.lightGray
            ]
            let appNameSize = appName.size(withAttributes: appNameAttributes)
            appName.draw(at: CGPoint(x: (size.width - appNameSize.width) / 2, y: size.height - 200), withAttributes: appNameAttributes)
        }
    }
    
    // MARK: - Analytics
    
    private func logEvent(_ event: AnalyticsEvent, parameters: [String: Any] = [:]) {
        print("Analytics Event: \(event.rawValue), parameters: \(parameters)")
    }
}

