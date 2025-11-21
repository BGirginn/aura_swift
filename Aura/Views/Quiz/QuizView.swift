//
//  QuizView.swift
//  Aura
//
//  Created by Aura Team
//

import SwiftUI

struct QuizView: View {
    
    @StateObject private var viewModel = QuizViewModel()
    @ObservedObject var coordinator: AppCoordinator
    
    var body: some View {
        ZStack {
            Color.auraBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with progress
                headerView
                
                // Question content
                if let question = viewModel.currentQuestion {
                    TabView(selection: $viewModel.currentQuestionIndex) {
                        ForEach(Array(viewModel.questions.enumerated()), id: \.offset) { index, q in
                            QuizQuestionCard(
                                question: q,
                                selectedAnswer: viewModel.getSelectedAnswer(for: q),
                                onSelectAnswer: { answer in
                                    viewModel.selectAnswer(answer)
                                }
                            )
                            .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                } else {
                    // Loading
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .auraAccent))
                }
                
                // Navigation buttons
                navigationButtons
            }
        }
        .onChange(of: viewModel.isCompleted) { completed in
            if completed, let result = viewModel.calculatedResult {
                coordinator.showResult(result)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: LayoutConstants.padding) {
            HStack {
                Button(action: { coordinator.showCamera() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundColor(.auraText)
                }
                
                Spacer()
                
                Text("Personality Quiz")
                    .font(.headline)
                    .foregroundColor(.auraText)
                
                Spacer()
                
                Text(viewModel.progressText)
                    .font(.subheadline)
                    .foregroundColor(.auraTextSecondary)
            }
            .padding(.horizontal, LayoutConstants.padding)
            
            // Progress bar
            ProgressView(value: viewModel.progress)
                .progressViewStyle(LinearProgressViewStyle(tint: .auraAccent))
                .padding(.horizontal, LayoutConstants.padding)
        }
        .padding(.top, LayoutConstants.padding)
    }
    
    // MARK: - Navigation Buttons
    
    private var navigationButtons: some View {
        HStack(spacing: LayoutConstants.padding) {
            // Previous button
            if viewModel.canGoPrevious {
                Button(action: viewModel.previousQuestion) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Previous")
                    }
                    .foregroundColor(.auraAccent)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.auraSurface)
                    .cornerRadius(LayoutConstants.cornerRadius)
                }
            }
            
            // Next/Finish button
            if viewModel.hasAnsweredCurrentQuestion {
                Button(action: {
                    if viewModel.currentQuestionIndex == viewModel.questions.count - 1 {
                        viewModel.completeQuiz()
                    } else {
                        viewModel.nextQuestion()
                    }
                }) {
                    HStack {
                        Text(viewModel.currentQuestionIndex == viewModel.questions.count - 1 ? "Finish" : "Next")
                        if viewModel.currentQuestionIndex < viewModel.questions.count - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.auraAccent)
                    .cornerRadius(LayoutConstants.cornerRadius)
                }
            }
        }
        .padding(LayoutConstants.padding)
    }
}

// MARK: - Quiz Question Card

struct QuizQuestionCard: View {
    
    let question: QuizQuestion
    let selectedAnswer: QuizAnswer?
    let onSelectAnswer: (QuizAnswer) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: LayoutConstants.largePadding) {
                // Question text
                Text(question.localizedQuestion)
                    .font(.title2)
                    .foregroundColor(.auraText)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, LayoutConstants.padding)
                    .padding(.top, LayoutConstants.largePadding)
                
                // Answer options
                VStack(spacing: LayoutConstants.padding) {
                    ForEach(question.answers) { answer in
                        AnswerButton(
                            answer: answer,
                            isSelected: selectedAnswer?.id == answer.id,
                            onTap: {
                                onSelectAnswer(answer)
                            }
                        )
                    }
                }
                .padding(.horizontal, LayoutConstants.padding)
                
                Spacer(minLength: 100)
            }
        }
    }
}

// MARK: - Answer Button

struct AnswerButton: View {
    
    let answer: QuizAnswer
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                // Radio circle
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.auraAccent : Color.auraTextSecondary, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.auraAccent)
                            .frame(width: 12, height: 12)
                    }
                }
                
                Text(answer.localizedText)
                    .font(.body)
                    .foregroundColor(.auraText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
            }
            .padding(LayoutConstants.padding)
            .background(
                RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                    .fill(Color.auraSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: LayoutConstants.cornerRadius)
                            .stroke(isSelected ? Color.auraAccent : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Preview

struct QuizView_Previews: PreviewProvider {
    static var previews: some View {
        QuizView(coordinator: AppCoordinator())
    }
}

