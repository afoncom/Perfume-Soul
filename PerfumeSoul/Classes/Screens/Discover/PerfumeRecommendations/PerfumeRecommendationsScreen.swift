//
//  PerfumeRecommendationsScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct PerfumeRecommendationsScreen: View {
    @Bindable private var viewModel: PerfumeRecommendationsViewModel
    private let presenter: PerfumeRecommendationsPresenter
    
    init(
        viewModel: PerfumeRecommendationsViewModel,
        presenter: PerfumeRecommendationsPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makeHeaderView()
                makeBasedOnSection()
                makeHintCard()
                makeRecommendationsSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .task {
            await presenter.onAppear()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension PerfumeRecommendationsScreen {
    func makeHeaderView() -> some View {
        Text(L10n.Screen.perfumeRecommendations)
            .font(.system(size: 30, weight: .medium, design: .rounded))
            .foregroundStyle(Color(.titleText))
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.bottom, 4)
    }
    
    func makeBasedOnSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("На основе ваших ароматов")
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
            
            HStack(spacing: 12) {
                makeBasePerfumeItem(title: "Bleu de\nChanel")
                makeBasePerfumeItem(title: "Dior\nSauvage")
                makeBasePerfumeItem(title: "YSL\nY Eau de Parfum")
                makeAddMoreItem()
            }
        }
    }
    
    func makeBasePerfumeItem(title: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 78)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeAddMoreItem() -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(.surfacePrimary))
                .frame(height: 78)
                .overlay {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundStyle(Color(.textPrimary))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(.cardBorder), lineWidth: 1)
                )
            
            Text("Добавить\nеще")
                .font(.caption)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeHintCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color(.zodiacPurple))
            
            Text("Мы проанализировали звучание и подобрали 5 ароматов, которые могут вам понравиться.")
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.purpleTable))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.tableBorder), lineWidth: 1)
        )
    }
    
    func makeRecommendationsSection() -> some View {
        VStack(spacing: 12) {
            if viewModel.isLoading {
                EmptyView()
            } else if viewModel.perfumeRecommendations.isEmpty {
                makeEmptyStateView()
            } else {
                ForEach(viewModel.perfumeRecommendations, id: \.id) { perfume in
                    makeRecommendationCard(
                        title: perfume.perfumeName,
                        brand: perfume.brandName,
                        accords: perfume.accords.joined(separator: " · "),
                        notes: "Созвучие: " + perfume.matchingNotes.joined(separator: ", "),
                        score: "\(perfume.matchPercentage)%"
                    )
                }
            }
        }
    }

    func makeEmptyStateView() -> some View {
        VStack(spacing: 8) {
            Text(L10n.PerfumeRecommendations.Empty.title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))

            Text(L10n.PerfumeRecommendations.Empty.subtitle)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .padding(.horizontal, 20)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeRecommendationCard(
        title: String,
        brand: String,
        accords: String,
        notes: String,
        score: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(width: 72, height: 96)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(brand)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
                
                Text(accords)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack(alignment: .top, spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.footnote)
                        .foregroundStyle(Color(.pinkButton))
                        .padding(.top, 2)
                    
                    Text(notes)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 8)
            
            VStack(alignment: .trailing, spacing: 12) {
                Text(score)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))
                
                Text("совпадение")
                    .font(.caption)
                    .foregroundStyle(Color(.textSecondary))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
            }
            .frame(width: 64)
        }
        .padding(12)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
}
