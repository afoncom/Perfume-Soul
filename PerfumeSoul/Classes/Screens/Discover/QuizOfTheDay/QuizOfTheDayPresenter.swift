//
//  QuizOfTheDayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol QuizOfTheDayPresenter {
    func onAppear() async
    func onCorrectAnswer() async
    func onQuizCompletion()
    func saveProgress(_ progress: QuizOfTheDayProgress)
}

final class QuizOfTheDayPresenterImpl {
    private let viewModel: QuizOfTheDayViewModel
    private let router: QuizOfTheDayRouter
    private let service: QuizOfTheDayService
    private let progressStorage: QuizOfTheDayProgressStorageImpl
    private let profileService: ProfileService
    
    init(
        viewModel: QuizOfTheDayViewModel,
        router: QuizOfTheDayRouter,
        service: QuizOfTheDayService,
        progressStorage: QuizOfTheDayProgressStorageImpl,
        profileService: ProfileService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
        self.progressStorage = progressStorage
        self.profileService = profileService
    }
}

extension QuizOfTheDayPresenterImpl: QuizOfTheDayPresenter {
    func onAppear() async {
        do {
            let questions = try await service.requestQuizOfTheDayQuestions()
            await MainActor.run {
                viewModel.errorMessage = nil
                viewModel.questions = questions
            }
        } catch {
            await MainActor.run {
                viewModel.errorMessage = L10n.Common.Error.message
            }
        }
    }
    
    func onCorrectAnswer() async {
        await profileService.incrementTotalCorrectQuizAnswers()
    }
    
    func onQuizCompletion() {
        progressStorage.completeQuiz()
    }
    
    func saveProgress(_ progress: QuizOfTheDayProgress) {
        progressStorage.saveProgress(progress)
    }
}
