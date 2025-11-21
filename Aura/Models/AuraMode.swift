//
//  AuraMode.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Different modes for aura detection
enum AuraMode: String, Codable, CaseIterable {
    case faceAura = "face_aura"        // Yüz Aurası
    case outfitAura = "outfit_aura"    // Kombin Aurası
    
    // Legacy support (deprecated)
    @available(*, deprecated, renamed: "faceAura")
    static var faceDetection: AuraMode { .faceAura }
    
    @available(*, deprecated, renamed: "outfitAura")
    static var photoAnalysis: AuraMode { .outfitAura }
    
    var displayName: String {
        switch self {
        case .faceAura:
            return "Face Aura"
        case .outfitAura:
            return "Outfit Aura"
        }
    }
    
    var displayNameTR: String {
        switch self {
        case .faceAura:
            return "Yüz Aurası"
        case .outfitAura:
            return "Kombin Aurası"
        }
    }
    
    var description: String {
        switch self {
        case .faceAura:
            return "Detect aura from your facial energy field using camera or gallery"
        case .outfitAura:
            return "Analyze colors from your outfit or environment using camera or gallery"
        }
    }
    
    var descriptionTR: String {
        switch self {
        case .faceAura:
            return "Kameradan veya galeriden yüzünüzün enerji alanından aura tespit edin"
        case .outfitAura:
            return "Kameradan veya galeriden kombinizdeki renklerden aura belirleyin"
        }
    }
    
    var icon: String {
        switch self {
        case .faceAura:
            return "person.crop.circle.fill"
        case .outfitAura:
            return "photo.fill"
        }
    }
    
    var resultTitle: String {
        switch self {
        case .faceAura:
            return "Your Facial Aura"
        case .outfitAura:
            return "Your Outfit Aura"
        }
    }
    
    var resultTitleTR: String {
        switch self {
        case .faceAura:
            return "Yüz Auranız"
        case .outfitAura:
            return "Kombin Auranız"
        }
    }
}

