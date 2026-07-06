//
//  PerfumeRecommendationsPresenter.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

protocol PerfumeRecommendationsPresenter {
    func onAppear() async
    @MainActor
    func recommendationTapped(_ perfume: PerfumeRecommendation)
}

final class PerfumeRecommendationsPresenterImpl {
    private let viewModel: PerfumeRecommendationsViewModel
    private let router: PerfumeRecommendationsRouter
    private let perfumeRecommendationService: PerfumeRecommendationService
    private let perfumeDetailsService: PerfumeDetailsService
    
    init(
        viewModel: PerfumeRecommendationsViewModel,
        router: PerfumeRecommendationsRouter,
        perfumeRecommendationService: PerfumeRecommendationService,
        perfumeDetailsService: PerfumeDetailsService
    ) {
        self.viewModel = viewModel
        self.router = router
        self.perfumeRecommendationService = perfumeRecommendationService
        self.perfumeDetailsService = perfumeDetailsService
    }
}

extension PerfumeRecommendationsPresenterImpl: PerfumeRecommendationsPresenter {
    func onAppear() async {
        await MainActor.run {
            viewModel.isLoading = true
            viewModel.errorMessage = nil
        }

        do {
            let perfumeRecommendations = try await perfumeRecommendationService.requestPerfumeRecommendations(
                perfumeIDs: viewModel.selectedPerfumes.map(\.id)
            )
            let detailsByID = try await loadPerfumeDetailsByID(
                perfumeIDs: viewModel.selectedPerfumes.map(\.id) + perfumeRecommendations.map(\.id)
            )
            let selectedPerfumeDetails = viewModel.selectedPerfumes.compactMap { detailsByID[$0.id] }
            let scoredPerfumeRecommendations = perfumeRecommendations
                .map { perfumeRecommendation in
                    var perfumeRecommendation = perfumeRecommendation

                    if let candidatePerfumeDetails = detailsByID[perfumeRecommendation.id] {
                        perfumeRecommendation.matchPercentage = calculateMatchPercentage(
                            selectedPerfumeDetails: selectedPerfumeDetails,
                            candidatePerfumeDetails: candidatePerfumeDetails
                        )
                    }

                    return perfumeRecommendation
                }
                .sorted { lhs, rhs in
                    if lhs.matchPercentage == rhs.matchPercentage {
                        if lhs.brandName == rhs.brandName {
                            return lhs.perfumeName < rhs.perfumeName
                        }

                        return lhs.brandName < rhs.brandName
                    }

                    return lhs.matchPercentage > rhs.matchPercentage
                }

            await MainActor.run {
                viewModel.perfumeRecommendations = scoredPerfumeRecommendations
                viewModel.isLoading = false
                viewModel.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                viewModel.perfumeRecommendations = []
                viewModel.isLoading = false
                viewModel.errorMessage = L10n.Common.Error.message
            }
        }
    }

    @MainActor func recommendationTapped(_ perfume: PerfumeRecommendation) {
        let fullName: String

        if perfume.perfumeName.localizedCaseInsensitiveContains(perfume.brandName), !perfume.brandName.isEmpty {
            fullName = perfume.perfumeName
        } else if perfume.brandName.isEmpty {
            fullName = perfume.perfumeName
        } else {
            fullName = "\(perfume.brandName) \(perfume.perfumeName)"
        }

        router.showPerfumeDetailsScreen(
            perfume: SearchPerfumeItem(
                id: perfume.id,
                name: fullName
            )
        )
    }
}

private extension PerfumeRecommendationsPresenterImpl {
    func loadPerfumeDetailsByID(perfumeIDs: [Int]) async throws -> [Int: PerfumeDetails] {
        let uniquePerfumeIDs = Array(Set(perfumeIDs))

        return try await withThrowingTaskGroup(of: PerfumeDetails.self) { group in
            for perfumeID in uniquePerfumeIDs {
                group.addTask {
                    try await self.perfumeDetailsService.requestPerfumeDetails(perfumeID: perfumeID)
                }
            }

            var detailsByID: [Int: PerfumeDetails] = [:]

            for try await perfumeDetails in group {
                detailsByID[perfumeDetails.id] = perfumeDetails
            }

            return detailsByID
        }
    }

    func calculateMatchPercentage(
        selectedPerfumeDetails: [PerfumeDetails],
        candidatePerfumeDetails: PerfumeDetails
    ) -> Int {
        guard !selectedPerfumeDetails.isEmpty else {
            return 0
        }

        let totalScore = selectedPerfumeDetails.reduce(0.0) { partialResult, selectedPerfumeDetails in
            partialResult + calculateMatchScore(
                selectedPerfumeDetails: selectedPerfumeDetails,
                candidatePerfumeDetails: candidatePerfumeDetails
            )
        }
        let averageScore = totalScore / Double(selectedPerfumeDetails.count)

        return min(
            100,
            max(0, Int((averageScore * 100).rounded(.toNearestOrAwayFromZero)))
        )
    }

    func calculateMatchScore(
        selectedPerfumeDetails: PerfumeDetails,
        candidatePerfumeDetails: PerfumeDetails
    ) -> Double {
        let noteScore = calculateWeightedNoteScore(
            selectedPerfumeDetails: selectedPerfumeDetails,
            candidatePerfumeDetails: candidatePerfumeDetails
        )
        let accordScore = calculateWeightedAccordScore(
            selectedAccords: selectedPerfumeDetails.accords,
            candidateAccords: candidatePerfumeDetails.accords
        )
        let familyScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.fragranceFamily,
            candidateValue: candidatePerfumeDetails.fragranceFamily
        )
        let concentrationScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.concentration,
            candidateValue: candidatePerfumeDetails.concentration
        )
        let seasonScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.seasonProfile,
            candidateValue: candidatePerfumeDetails.seasonProfile
        )
        let occasionScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.occasionProfile,
            candidateValue: candidatePerfumeDetails.occasionProfile
        )
        let styleScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.styleProfile,
            candidateValue: candidatePerfumeDetails.styleProfile
        )
        let genderScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.genderProfile,
            candidateValue: candidatePerfumeDetails.genderProfile
        )
        let moodScore = calculateDescriptorSimilarity(
            selectedValue: selectedPerfumeDetails.moodProfile,
            candidateValue: candidatePerfumeDetails.moodProfile
        )
        let wearScore = calculateWearScore(
            selectedPerfumeDetails: selectedPerfumeDetails,
            candidatePerfumeDetails: candidatePerfumeDetails
        )

        var weightedComponents: [(Double, Double)] = [
            (noteScore, 0.27)
        ]

        if let accordScore {
            weightedComponents.append((accordScore, 0.17))
        }

        if let familyScore {
            weightedComponents.append((familyScore, 0.07))
        }

        if let wearScore {
            weightedComponents.append((wearScore, 0.08))
        }

        if let concentrationScore {
            weightedComponents.append((concentrationScore, 0.04))
        }

        if let seasonScore {
            weightedComponents.append((seasonScore, 0.08))
        }

        if let occasionScore {
            weightedComponents.append((occasionScore, 0.08))
        }

        if let styleScore {
            weightedComponents.append((styleScore, 0.08))
        }

        if let genderScore {
            weightedComponents.append((genderScore, 0.07))
        }

        if let moodScore {
            weightedComponents.append((moodScore, 0.06))
        }

        let totalWeight = weightedComponents.reduce(0.0) { $0 + $1.1 }
        guard totalWeight > 0 else {
            return 0
        }

        let weightedScore = weightedComponents.reduce(0.0) { partialResult, component in
            partialResult + component.0 * component.1
        }

        return weightedScore / totalWeight
    }

    func calculateWeightedNoteScore(
        selectedPerfumeDetails: PerfumeDetails,
        candidatePerfumeDetails: PerfumeDetails
    ) -> Double {
        let layerScores: [(Double, Double)] = [
            (
                calculateLayerSimilarity(
                    selectedNotes: selectedPerfumeDetails.topNotes,
                    candidateNotes: candidatePerfumeDetails.topNotes
                ),
                0.45
            ),
            (
                calculateLayerSimilarity(
                    selectedNotes: selectedPerfumeDetails.middleNotes,
                    candidateNotes: candidatePerfumeDetails.middleNotes
                ),
                0.35
            ),
            (
                calculateLayerSimilarity(
                    selectedNotes: selectedPerfumeDetails.baseNotes,
                    candidateNotes: candidatePerfumeDetails.baseNotes
                ),
                0.2
            )
        ]

        let availableLayerScores = layerScores.filter { $0.0 >= 0 }
        let totalWeight = availableLayerScores.reduce(0.0) { $0 + $1.1 }
        guard totalWeight > 0 else {
            return 0
        }

        let weightedScore = availableLayerScores.reduce(0.0) { partialResult, layer in
            partialResult + layer.0 * layer.1
        }
        let noteCountScore = calculateNoteCountScore(
            selectedPerfumeDetails: selectedPerfumeDetails,
            candidatePerfumeDetails: candidatePerfumeDetails
        )

        return (weightedScore / totalWeight) * 0.85 + noteCountScore * 0.15
    }

    func calculateLayerSimilarity(
        selectedNotes: [String],
        candidateNotes: [String]
    ) -> Double {
        let normalizedSelectedNotes = Set(selectedNotes.map(normalize))
        guard !normalizedSelectedNotes.isEmpty else {
            return -1
        }

        let normalizedCandidateNotes = Set(candidateNotes.map(normalize))
        let matchingNotesCount = normalizedSelectedNotes.intersection(normalizedCandidateNotes).count
        let coverage = Double(matchingNotesCount) / Double(normalizedSelectedNotes.count)
        guard !normalizedCandidateNotes.isEmpty else {
            return coverage * 0.7
        }

        let precision = Double(matchingNotesCount) / Double(normalizedCandidateNotes.count)
        return coverage * 0.7 + precision * 0.3
    }

    func calculateNoteCountScore(
        selectedPerfumeDetails: PerfumeDetails,
        candidatePerfumeDetails: PerfumeDetails
    ) -> Double {
        let selectedCount =
            selectedPerfumeDetails.topNotes.count
            + selectedPerfumeDetails.middleNotes.count
            + selectedPerfumeDetails.baseNotes.count
        let candidateCount =
            candidatePerfumeDetails.topNotes.count
            + candidatePerfumeDetails.middleNotes.count
            + candidatePerfumeDetails.baseNotes.count
        let maxCount = max(selectedCount, candidateCount)

        guard maxCount > 0 else {
            return 0
        }

        return max(0, 1 - (Double(abs(selectedCount - candidateCount)) / Double(maxCount)))
    }

    func calculateWearScore(
        selectedPerfumeDetails: PerfumeDetails,
        candidatePerfumeDetails: PerfumeDetails
    ) -> Double? {
        var scores: [Double] = []

        if let longevityScore = calculateScoreSimilarity(
            selectedScore: selectedPerfumeDetails.longevityScore,
            candidateScore: candidatePerfumeDetails.longevityScore
        ) {
            scores.append(longevityScore)
        }

        if let sillageScore = calculateScoreSimilarity(
            selectedScore: selectedPerfumeDetails.sillageScore,
            candidateScore: candidatePerfumeDetails.sillageScore
        ) {
            scores.append(sillageScore)
        }

        guard !scores.isEmpty else {
            return nil
        }

        return scores.reduce(0, +) / Double(scores.count)
    }

    func calculateWeightedAccordScore(
        selectedAccords: [PerfumeAccord],
        candidateAccords: [PerfumeAccord]
    ) -> Double? {
        let normalizedSelectedAccords = Dictionary(
            uniqueKeysWithValues: selectedAccords.map {
                (normalize($0.name), $0.weight)
            }
        )
        guard !normalizedSelectedAccords.isEmpty else {
            return nil
        }

        let normalizedCandidateAccords = Dictionary(
            uniqueKeysWithValues: candidateAccords.map {
                (normalize($0.name), $0.weight)
            }
        )
        let allAccordNames = Set(normalizedSelectedAccords.keys).union(normalizedCandidateAccords.keys)
        let overlapWeight = allAccordNames.reduce(0.0) { partialResult, accordName in
            partialResult + min(
                normalizedSelectedAccords[accordName] ?? 0,
                normalizedCandidateAccords[accordName] ?? 0
            )
        }

        let selectedTotalWeight = normalizedSelectedAccords.values.reduce(0, +)
        guard selectedTotalWeight > 0 else {
            return nil
        }

        let candidateTotalWeight = normalizedCandidateAccords.values.reduce(0, +)
        let coverage = overlapWeight / selectedTotalWeight
        let precision = candidateTotalWeight > 0 ? overlapWeight / candidateTotalWeight : 0

        return coverage * 0.70 + precision * 0.30
    }

    func calculateDescriptorSimilarity(
        selectedValue: String?,
        candidateValue: String?
    ) -> Double? {
        guard
            let selectedTokens = normalizedTokens(from: selectedValue),
            let candidateTokens = normalizedTokens(from: candidateValue)
        else {
            return nil
        }

        if selectedTokens == candidateTokens {
            return 1
        }

        let overlapCount = selectedTokens.intersection(candidateTokens).count
        guard overlapCount > 0 else {
            return 0
        }

        let coverage = Double(overlapCount) / Double(selectedTokens.count)
        let precision = Double(overlapCount) / Double(candidateTokens.count)
        return coverage * 0.7 + precision * 0.3
    }

    func calculateScoreSimilarity(
        selectedScore: Int?,
        candidateScore: Int?
    ) -> Double? {
        guard
            let selectedScore,
            let candidateScore
        else {
            return nil
        }

        let maxDistance = 9.0
        let distance = abs(Double(selectedScore - candidateScore))
        return max(0, 1 - (distance / maxDistance))
    }

    func normalize(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    func normalizedTokens(from value: String?) -> Set<String>? {
        guard let value else {
            return nil
        }

        let tokens = value
            .split(separator: " ")
            .map(String.init)
            .map(normalize)
            .filter { !$0.isEmpty }

        guard !tokens.isEmpty else {
            return nil
        }

        return Set(tokens)
    }
}
