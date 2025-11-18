//
//  LocalizationService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Service for managing localized aura color descriptions
class LocalizationService {
    
    static let shared = LocalizationService()
    
    private var auraDescriptions: [String: AuraColorDescription] = [:]
    
    struct AuraColorDescription: Codable {
        let colorId: String
        let descriptions: [String: LocalizedContent]
        
        struct LocalizedContent: Codable {
            let countryCode: String
            let short: String
            let long: String
            let traits: [String]
            let advice: String
        }
    }
    
    private init() {
        loadAuraDescriptions()
    }
    
    // MARK: - Public Methods
    
    /// Get localized description for an aura color
    func getDescription(for auraColor: AuraColor, countryCode: String? = nil) -> AuraColor.LocalizedDescription? {
        let code = countryCode ?? Locale.current.regionCode ?? "US"
        
        // Try to get from loaded descriptions
        if let description = auraDescriptions[auraColor.id]?.descriptions[code] {
            return AuraColor.LocalizedDescription(
                countryCode: description.countryCode,
                shortDescription: description.short,
                longDescription: description.long,
                traits: description.traits,
                advice: description.advice
            )
        }
        
        // Fallback to default
        if let defaultDescription = auraDescriptions[auraColor.id]?.descriptions["default"] {
            return AuraColor.LocalizedDescription(
                countryCode: "default",
                shortDescription: defaultDescription.short,
                longDescription: defaultDescription.long,
                traits: defaultDescription.traits,
                advice: defaultDescription.advice
            )
        }
        
        return nil
    }
    
    /// Get short description
    func getShortDescription(for auraColor: AuraColor, countryCode: String? = nil) -> String {
        return getDescription(for: auraColor, countryCode: countryCode)?.shortDescription ?? "No description available"
    }
    
    /// Get long description
    func getLongDescription(for auraColor: AuraColor, countryCode: String? = nil) -> String {
        return getDescription(for: auraColor, countryCode: countryCode)?.longDescription ?? "No description available"
    }
    
    // MARK: - Private Methods
    
    private func loadAuraDescriptions() {
        // Load from JSON file in Resources
        guard let url = Bundle.main.url(forResource: "aura_comments", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let descriptions = try? JSONDecoder().decode([String: AuraColorDescription].self, from: data) else {
            loadDefaultDescriptions()
            return
        }
        
        auraDescriptions = descriptions
    }
    
    private func loadDefaultDescriptions() {
        // Fallback default descriptions
        auraDescriptions = [
            "aura_red": AuraColorDescription(
                colorId: "aura_red",
                descriptions: [
                    "default": .init(
                        countryCode: "default",
                        short: "Passion and energy",
                        long: "Red aura represents strong energy, passion, and vitality. You are a natural leader with powerful emotions.",
                        traits: ["Energetic", "Passionate", "Strong-willed"],
                        advice: "Channel your energy into productive activities"
                    ),
                    "TR": .init(
                        countryCode: "TR",
                        short: "Tutku ve enerji",
                        long: "Kırmızı aura güçlü enerji, tutku ve canlılığı temsil eder. Doğal bir lidersiniz ve güçlü duygulara sahipsiniz.",
                        traits: ["Enerjik", "Tutkulu", "Güçlü iradeli"],
                        advice: "Enerjinizi verimli aktivitelere yönlendirin"
                    )
                ]
            ),
            "aura_yellow": AuraColorDescription(
                colorId: "aura_yellow",
                descriptions: [
                    "default": .init(
                        countryCode: "default",
                        short: "Clarity and optimism",
                        long: "Yellow aura reflects intellectual clarity, optimism, and joy. You have a bright and analytical mind.",
                        traits: ["Optimistic", "Intelligent", "Joyful"],
                        advice: "Share your positive energy with others"
                    ),
                    "TR": .init(
                        countryCode: "TR",
                        short: "Açıklık ve iyimserlik",
                        long: "Sarı aura zihinsel berraklık, iyimserlik ve neşeyi yansıtır. Parlak ve analitik bir zihne sahipsiniz.",
                        traits: ["İyimser", "Zeki", "Neşeli"],
                        advice: "Pozitif enerjinizi başkalarıyla paylaşın"
                    )
                ]
            ),
            "aura_blue": AuraColorDescription(
                colorId: "aura_blue",
                descriptions: [
                    "default": .init(
                        countryCode: "default",
                        short: "Calm and intuitive",
                        long: "Blue aura indicates calmness, intuition, and strong communication skills. You are a natural healer and empath.",
                        traits: ["Calm", "Intuitive", "Communicative"],
                        advice: "Trust your intuition and speak your truth"
                    ),
                    "TR": .init(
                        countryCode: "TR",
                        short: "Sakinlik ve sezgi",
                        long: "Mavi aura sakinliği, sezgiyi ve güçlü iletişim becerilerini gösterir. Doğal bir şifacı ve empatisiniz.",
                        traits: ["Sakin", "Sezgisel", "İletişim becerisi yüksek"],
                        advice: "Sezgilerinize güvenin ve gerçeğinizi konuşun"
                    )
                ]
            )
        ]
    }
}

