//
//  QuizViewModel.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI
import Combine

/// ViewModel for quiz-based aura detection
class QuizViewModel: ObservableObject {
    
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex = 0
    @Published var answers: [QuizAnswerRecord] = []
    @Published var isCompleted = false
    @Published var calculatedResult: AuraResult?
    
    private let quizService: QuizService
    
    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    var progressText: String {
        "\(currentQuestionIndex + 1)/\(questions.count)"
    }
    
    var canGoNext: Bool {
        hasAnsweredCurrentQuestion && currentQuestionIndex < questions.count - 1
    }
    
    var canGoPrevious: Bool {
        currentQuestionIndex > 0
    }
    
    var hasAnsweredCurrentQuestion: Bool {
        guard let current = currentQuestion else { return false }
        return answers.contains(where: { $0.questionId == current.id })
    }
    
    init(quizService: QuizService = .shared) {
        self.quizService = quizService
        loadQuestions()
    }
    
    // MARK: - Load Questions
    
    func loadQuestions() {
        questions = quizService.getQuestions()
    }
    
    // MARK: - Answer Selection
    
    func selectAnswer(_ answer: QuizAnswer) {
        guard let currentQuestion = currentQuestion else { return }
        
        // Remove previous answer for this question (if exists)
        answers.removeAll(where: { $0.questionId == currentQuestion.id })
        
        // Add new answer
        let record = QuizAnswerRecord(
            questionId: currentQuestion.id,
            answerId: answer.id,
            timestamp: Date()
        )
        answers.append(record)
        
        // Haptic feedback
        HapticManager.shared.selection()
        
        // Auto-advance to next question after short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            self?.nextQuestion()
        }
    }
    
    func getSelectedAnswer(for question: QuizQuestion) -> QuizAnswer? {
        guard let record = answers.first(where: { $0.questionId == question.id }) else {
            return nil
        }
        return question.answers.first(where: { $0.id == record.answerId })
    }
    
    // MARK: - Navigation
    
    func nextQuestion() {
        guard canGoNext else {
            completeQuiz()
            return
        }
        
        withAnimation {
            currentQuestionIndex += 1
        }
    }
    
    func previousQuestion() {
        guard canGoPrevious else { return }
        
        withAnimation {
            currentQuestionIndex -= 1
        }
    }
    
    func goToQuestion(_ index: Int) {
        guard index >= 0 && index < questions.count else { return }
        
        withAnimation {
            currentQuestionIndex = index
        }
    }
    
    // MARK: - Complete Quiz
    
    func completeQuiz() {
        guard answers.count == questions.count else {
            print("❌ Not all questions answered")
            return
        }
        
        // Calculate result
        calculatedResult = quizService.calculateAuraResult(from: answers)
        
        if calculatedResult != nil {
            isCompleted = true
            HapticManager.shared.success()
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        currentQuestionIndex = 0
        answers = []
        isCompleted = false
        calculatedResult = nil
    }
}

