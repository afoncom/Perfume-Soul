//
//  PersonalPerfumePresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PersonalPerfumePresenter {
    var shouldShowContinueButton: Bool { get }

    func onAppear() async
    func retryButtonTapped() async
    func continueButtonTapped()
}

final class PersonalPerfumePresenterImpl {
    private let viewModel: PersonalPerfumeViewModel
    private let router: PersonalPerfumeRouter
    private let service: PersonalPerfumeService
    private let profileCalculation: ProfileCalculation?
    let shouldShowContinueButton: Bool
    
    init(
        viewModel: PersonalPerfumeViewModel,
        router: PersonalPerfumeRouter,
        service: PersonalPerfumeService,
        profileCalculation: ProfileCalculation?,
        shouldShowContinueButton: Bool
    ) {
        self.viewModel = viewModel
        self.router = router
        self.service = service
        self.profileCalculation = profileCalculation
        self.shouldShowContinueButton = shouldShowContinueButton
    }
}

extension PersonalPerfumePresenterImpl: PersonalPerfumePresenter {
    func onAppear() async {
        await loadPersonalPerfumes()
    }

    func retryButtonTapped() async {
        await loadPersonalPerfumes()
    }

    func continueButtonTapped() {
        guard viewModel.canContinue else {
            return
        }

        router.finishOnboarding()
    }
}

extension PersonalPerfumePresenterImpl {
    private func loadPersonalPerfumes() async {
        guard let profileCalculation else {
            await MainActor.run {
                viewModel.state = .missingProfileCalculation
            }
            return
        }

        await MainActor.run {
            viewModel.state = .loading
        }

        do {
            let perfumes = try await service.requestPersonalPerfumes(
                profile: makeProfileRequest(profileCalculation: profileCalculation)
            )
            let sections = makeSections(perfumes: perfumes)

            await MainActor.run {
                viewModel.state = sections.isEmpty ? .empty : .content(sections)
            }
        } catch {
            await MainActor.run {
                viewModel.state = .requestFailed
            }
        }
    }

    private func makeProfileRequest(profileCalculation: ProfileCalculation) -> PersonalPerfumeProfileRequest {
        PersonalPerfumeProfileRequest(
            sun: profileCalculation.natalChart.sun.sign.rawValue,
            moon: profileCalculation.natalChart.moon.sign.rawValue,
            ascendant: profileCalculation.natalChart.ascendant.sign.rawValue,
            elementBalance: PersonalPerfumeElementBalanceRequest(
                fire: profileCalculation.elementBalance.fire,
                earth: profileCalculation.elementBalance.earth,
                air: profileCalculation.elementBalance.air,
                water: profileCalculation.elementBalance.water
            )
        )
    }

    private func makeSections(perfumes: [PersonalPerfumeResponse]) -> [PersonalPerfumeSection] {
        PersonalPerfumeMarketSegment.allCases.compactMap { segment in
            let segmentPerfumes = perfumes.filter { $0.marketSegment == segment }
            guard !segmentPerfumes.isEmpty else {
                return nil
            }

            return PersonalPerfumeSection(
                title: title(for: segment),
                perfumes: segmentPerfumes.map { perfume in
                    PersonalPerfumeItem(
                        name: perfume.brandName,
                        subtitle: perfume.perfumeName,
                        matchExplanation: makeMatchExplanation(perfume: perfume),
                        matchPercentage: perfume.matchPercentage
                    )
                },
                description: description(for: segment)
            )
        }
    }

    private func title(for segment: PersonalPerfumeMarketSegment) -> String {
        switch segment {
        case .luxury:
            L10n.PersonalPerfume.Section.Luxury.title
        case .daily:
            L10n.PersonalPerfume.Section.Daily.title
        case .niche:
            L10n.PersonalPerfume.Section.Niche.title
        }
    }

    private func description(for segment: PersonalPerfumeMarketSegment) -> String {
        switch segment {
        case .luxury:
            L10n.PersonalPerfume.Section.Luxury.description
        case .daily:
            L10n.PersonalPerfume.Section.Daily.description
        case .niche:
            L10n.PersonalPerfume.Section.Niche.description
        }
    }

    private func makeMatchExplanation(perfume: PersonalPerfumeResponse) -> String? {
        let matchedValues = (perfume.matchingNotes + perfume.matchingAccords)
            .filter { !$0.isEmpty }
            .prefix(4)

        guard !matchedValues.isEmpty else {
            return nil
        }

        return L10n.PersonalPerfume.matchExplanationFormat(matchedValues.joined(separator: ", "))
    }
}
