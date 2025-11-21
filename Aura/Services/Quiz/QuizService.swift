//
//  QuizService.swift
//  Aura
//
//  Created by Aura Team
//

import Foundation

/// Service for quiz-based aura detection
class QuizService {
    
    static let shared = QuizService()
    
    private var questions: [QuizQuestion] = []
    
    private init() {
        loadQuestions()
    }
    
    // MARK: - Load Questions
    
    func loadQuestions() {
        guard let url = Bundle.main.url(forResource: "quiz_questions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let loadedQuestions = try? JSONDecoder().decode([QuizQuestion].self, from: data) else {
            print("❌ Failed to load quiz questions")
            return
        }
        
        questions = loadedQuestions
        print("✅ Loaded \(questions.count) quiz questions")
    }
    
    func getQuestions() -> [QuizQuestion] {
        return questions
    }
    
    // MARK: - Calculate Result
    
    func calculateAuraResult(from answers: [QuizAnswerRecord]) -> AuraResult? {
        guard !answers.isEmpty else { return nil }
        
        // Build color scores with weighted algorithm
        var colorScores: [String: Double] = [:] // [AuraColor ID: Score]
        
        for answer in answers {
            // Find the question and answer
            guard let question = questions.first(where: { $0.id == answer.questionId }),
                  let selectedAnswer = question.answers.first(where: { $0.id == answer.answerId }) else {
                continue
            }
            
            // Add primary color score
            let primaryId = selectedAnswer.primaryColor
            colorScores[primaryId, default: 0] += selectedAnswer.weight * 3.0
            
            // Add secondary color score (if exists)
            if let secondaryId = selectedAnswer.secondaryColor {
                colorScores[secondaryId, default: 0] += selectedAnswer.weight * 1.0
            }
        }
        
        // Sort by score
        let sortedColors = colorScores.sorted { $0.value > $1.value }
        
        guard sortedColors.count >= 1 else { return nil }
        
        // Get top 3 colors
        let primaryColorId = sortedColors[0].key
        let secondaryColorId = sortedColors.count > 1 ? sortedColors[1].key : nil
        let tertiaryColorId = sortedColors.count > 2 ? sortedColors[2].key : nil
        
        // Convert IDs to AuraColor objects
        guard let primaryColor = AuraColor.allColors.first(where: { $0.id == primaryColorId }) else {
            return nil
        }
        
        let secondaryColor = secondaryColorId != nil ? AuraColor.allColors.first(where: { $0.id == secondaryColorId }) : nil
        let tertiaryColor = tertiaryColorId != nil ? AuraColor.allColors.first(where: { $0.id == tertiaryColorId }) : nil
        
        // Calculate percentages
        let totalScore = sortedColors.prefix(3).reduce(0.0) { $0 + $1.value }
        var percentages: [Double] = []
        
        for i in 0..<min(3, sortedColors.count) {
            let percentage = (sortedColors[i].value / totalScore) * 100.0
            percentages.append(percentage)
        }
        
        // Create result
        return AuraResult(
            timestamp: Date(),
            primaryColor: primaryColor,
            secondaryColor: secondaryColor,
            tertiaryColor: tertiaryColor,
            dominancePercentages: percentages,
            countryCode: Locale.current.regionCode ?? "US",
            imageData: nil
        )
    }
}

