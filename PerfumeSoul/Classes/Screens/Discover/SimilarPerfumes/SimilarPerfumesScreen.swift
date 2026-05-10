//
//  SimilarPerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 10.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SimilarPerfumesScreen: View {
    @Bindable private var viewModel: SimilarPerfumesViewModel
    private let presenter: SimilarPerfumesPresenter
    
    init(
        viewModel: SimilarPerfumesViewModel,
        presenter: SimilarPerfumesPresenter
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
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension SimilarPerfumesScreen {
    func makeHeaderView() -> some View {
        Text(L10n.Screen.similarPerfumes)
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
            makeRecommendationCard(
                title: "Prada Luna Rossa Black",
                brand: "Prada",
                accords: "Теплый · Пряный · Древесный",
                notes: "Созвучие: амбра, лаванда, древесные ноты",
                score: "92%"
            )
            
            makeRecommendationCard(
                title: "Giorgio Armani Acqua di Giò Profondo",
                brand: "Giorgio Armani",
                accords: "Морской · Ароматический · Свежий",
                notes: "Созвучие: бергамот, лаванда, морские ноты",
                score: "89%"
            )
            
            makeRecommendationCard(
                title: "Chanel Allure Homme Sport",
                brand: "Chanel",
                accords: "Цитрусовый · Пряный · Древесный",
                notes: "Созвучие: цитрусы, мускус, кедр",
                score: "86%"
            )
            
            makeRecommendationCard(
                title: "Yves Saint Laurent Y Le Parfum",
                brand: "YSL",
                accords: "Древесный · Ароматический · Элегантный",
                notes: "Созвучие: лаванда, амбра, пачули",
                score: "84%"
            )
            
            makeRecommendationCard(
                title: "Dior Homme Intense",
                brand: "Dior",
                accords: "Пудровый · Древесный · Ирисовый",
                notes: "Созвучие: ирис, амбра, древесные ноты",
                score: "82%"
            )
        }
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
