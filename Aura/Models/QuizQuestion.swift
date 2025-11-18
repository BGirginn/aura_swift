//
//  QuizQuestion.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Quiz question for personality-based aura detection
struct QuizQuestion: Identifiable, Codable {
    let id: String
    let category: QuestionCategory
    let questionEN: String
    let questionTR: String
    let answers: [QuizAnswer]
    
    enum QuestionCategory: String, Codable {
        case emotional = "emotional"
        case decision = "decision"
        case energy = "energy"
        case relationship = "relationship"
    }
    
    var localizedQuestion: String {
        let language = Locale.current.languageCode ?? "en"
        return language.hasPrefix("tr") ? questionTR : questionEN
    }
}

/// Answer option for a quiz question
struct QuizAnswer: Identifiable, Codable {
    let id: String
    let textEN: String
    let textTR: String
    let primaryColor: String // AuraColor ID
    let secondaryColor: String? // Optional secondary color boost
    let weight: Double // How strongly this answer indicates this color (1.0-3.0)
    
    var localizedText: String {
        let language = Locale.current.languageCode ?? "en"
        return language.hasPrefix("tr") ? textTR : textEN
    }
    
    var auraColor: AuraColor? {
        AuraColor.allColors.first(where: { $0.id == primaryColor })
    }
    
    var secondaryAuraColor: AuraColor? {
        guard let secondary = secondaryColor else { return nil }
        return AuraColor.allColors.first(where: { $0.id == secondary })
    }
}

/// Result from quiz-based aura detection
struct QuizAnswerRecord: Codable {
    let questionId: String
    let answerId: String
    let timestamp: Date
}

