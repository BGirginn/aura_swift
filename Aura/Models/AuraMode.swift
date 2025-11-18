//
//  AuraMode.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Different modes for aura detection
enum AuraMode: String, Codable, CaseIterable {
    case quiz = "quiz"
    case photoAnalysis = "photo_analysis"
    case faceDetection = "face_detection"
    
    var displayName: String {
        switch self {
        case .quiz:
            return "Personality Quiz"
        case .photoAnalysis:
            return "Photo Analysis"
        case .faceDetection:
            return "Face Aura"
        }
    }
    
    var displayNameTR: String {
        switch self {
        case .quiz:
            return "Kişilik Testi"
        case .photoAnalysis:
            return "Fotoğraf Analizi"
        case .faceDetection:
            return "Yüz Aurası"
        }
    }
    
    var description: String {
        switch self {
        case .quiz:
            return "Answer psychological questions to discover your aura"
        case .photoAnalysis:
            return "Analyze colors from your outfit or environment"
        case .faceDetection:
            return "Detect aura from facial energy field"
        }
    }
    
    var descriptionTR: String {
        switch self {
        case .quiz:
            return "Psikolojik sorularla auranızı keşfedin"
        case .photoAnalysis:
            return "Kombininizdeki veya çevrenizdeki renklerden aura belirleyin"
        case .faceDetection:
            return "Yüzünüzün enerji alanından aura tespit edin"
        }
    }
    
    var icon: String {
        switch self {
        case .quiz:
            return "questionmark.circle.fill"
        case .photoAnalysis:
            return "photo.fill"
        case .faceDetection:
            return "person.crop.circle.fill"
        }
    }
    
    var resultTitle: String {
        switch self {
        case .quiz:
            return "Your Personality Aura"
        case .photoAnalysis:
            return "Your Color Energy"
        case .faceDetection:
            return "Your Facial Aura"
        }
    }
    
    var resultTitleTR: String {
        switch self {
        case .quiz:
            return "Kişilik Auranız"
        case .photoAnalysis:
            return "Renk Enerjiniz"
        case .faceDetection:
            return "Yüz Auranız"
        }
    }
}

