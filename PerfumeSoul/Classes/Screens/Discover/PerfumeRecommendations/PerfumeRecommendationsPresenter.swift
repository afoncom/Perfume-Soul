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
        let wearScore = calculateWearScore(
            selectedPerfumeDetails: selectedPerfumeDetails,
            candidatePerfumeDetails: candidatePerfumeDetails
        )

        if let wearScore {
            return noteScore * 0.85 + wearScore * 0.15
        }

        return noteScore
    }

    func calculateWeightedNoteScore(
        selectedPerfumeDetails: PerfumeDetails,
        candidatePerfumeDetails: PerfumeDetails
    ) -> Double {
        let layerScores: [(Double, Double)] = [
            (
                calculateLayerOverlap(
                    selectedNotes: selectedPerfumeDetails.topNotes,
                    candidateNotes: candidatePerfumeDetails.topNotes
                ),
                0.45
            ),
            (
                calculateLayerOverlap(
                    selectedNotes: selectedPerfumeDetails.middleNotes,
                    candidateNotes: candidatePerfumeDetails.middleNotes
                ),
                0.35
            ),
            (
                calculateLayerOverlap(
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

        return weightedScore / totalWeight
    }

    func calculateLayerOverlap(
        selectedNotes: [String],
        candidateNotes: [String]
    ) -> Double {
        let normalizedSelectedNotes = Set(selectedNotes.map(normalize))
        guard !normalizedSelectedNotes.isEmpty else {
            return -1
        }

        let normalizedCandidateNotes = Set(candidateNotes.map(normalize))
        let matchingNotesCount = normalizedSelectedNotes.intersection(normalizedCandidateNotes).count

        return Double(matchingNotesCount) / Double(normalizedSelectedNotes.count)
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
}
