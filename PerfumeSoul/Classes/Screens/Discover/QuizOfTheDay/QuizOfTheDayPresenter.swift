//
//  QuizOfTheDayPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol QuizOfTheDayPresenter {
    func onAppear() async
}

final class QuizOfTheDayPresenterImpl {
    private let viewModel: QuizOfTheDayViewModel
    private let router: QuizOfTheDayRouter
    private let service: QuizOfTheDayService

    init(
        viewModel: QuizOfTheDayViewModel,
        router: QuizOfTheDayRouter,
        service: QuizOfTheDayService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
    }
}

extension QuizOfTheDayPresenterImpl: QuizOfTheDayPresenter {
    func onAppear() async {
        do {
            let questions = try await service.requestQuizOfTheDayQuestions()
            await MainActor.run {
                viewModel.questions = questions
                viewModel.selectedAnswerId = nil
            }
        } catch {
            print(error)
        }
    }
}
