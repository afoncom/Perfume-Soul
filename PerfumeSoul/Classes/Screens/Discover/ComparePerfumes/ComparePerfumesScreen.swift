//
//  ComparePerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ComparePerfumesScreen: View {
    @Bindable private var viewModel: ComparePerfumesViewModel
    private let presenter: ComparePerfumesPresenter
    
    init(
        viewModel: ComparePerfumesViewModel,
        presenter: ComparePerfumesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                makePerfumesHeader()
                makeAccordsSection()
                makeNotesSection()
                makeImpressionSection()
                makePerformanceSection()
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 28)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .navigationTitle("Сравнение ароматов")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension ComparePerfumesScreen {
    func makePerfumesHeader() -> some View {
        ZStack {
            HStack(alignment: .top, spacing: 12) {
                makePerfumeCard(
                    brand: "Tom Ford",
                    name: "Oud Wood",
                    type: "Парфюмерная вода"
                )
                
                makePerfumeCard(
                    brand: "Dior",
                    name: "Sauvage",
                    type: "Парфюмерная вода"
                )
            }
            
            Text("VS")
                .font(.headline)
                .foregroundStyle(Color(.textSecondary))
                .frame(width: 44, height: 44)
                .background(Color(.surfacePrimary))
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(.cardBorder), lineWidth: 1)
                )
                .offset(y: -42)
        }
    }
    
    func makePerfumeCard(
        brand: String,
        name: String,
        type: String
    ) -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 156)
            
            VStack(spacing: 4) {
                Text(brand)
                    .font(.headline)
                    .foregroundStyle(Color(.textSecondary))
                
                Text(name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(type)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeAccordsSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle("Основные аккорды")
            
            VStack(spacing: 14) {
                makeAccordRow(title: "Древесный", leftValue: 0.86, rightValue: 0.92)
                makeAccordRow(title: "Удовый", leftValue: 0.72, rightValue: 0.34)
                makeAccordRow(title: "Теплый пряный", leftValue: 0.76, rightValue: 0.52)
                makeAccordRow(title: "Свежий пряный", leftValue: 0.46, rightValue: 0.78)
                makeAccordRow(title: "Дымный", leftValue: 0.38, rightValue: 0.56)
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeAccordRow(
        title: String,
        leftValue: CGFloat,
        rightValue: CGFloat
    ) -> some View {
        HStack(spacing: 10) {
            HStack {
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color(.pinkButton).opacity(0.55))
                    .frame(width: 72 * leftValue, height: 10)
                
                Spacer(minLength: 0)
            }
            .frame(width: 72)
            
            Text(title)
                .font(.footnote)
                .foregroundStyle(Color(.textPrimary))
                .frame(width: 92)
                .multilineTextAlignment(.center)
            
            HStack {
                Spacer(minLength: 0)
                
                RoundedRectangle(cornerRadius: 999, style: .continuous)
                    .fill(Color(.zodiacPurple).opacity(0.55))
                    .frame(width: 72 * rightValue, height: 10)
            }
            .frame(width: 72)
        }
    }
    
    func makeNotesSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle("Ноты")
            
            VStack(spacing: 18) {
                makeNotesRow(
                    title: "Верхние ноты",
                    leftNotes: ["Кардамон", "Перец", "Палисандр"],
                    rightNotes: ["Бергамот", "Перец", "Лаванда"]
                )
                
                makeNotesRow(
                    title: "Средние ноты",
                    leftNotes: ["Уд", "Сандал", "Ветивер"],
                    rightNotes: ["Лаванда", "Сычуанский перец", "Пачули"]
                )
                
                makeNotesRow(
                    title: "Базовые ноты",
                    leftNotes: ["Амбра", "Бобы тонка", "Ваниль"],
                    rightNotes: ["Амброксан", "Кедр", "Лабданум"]
                )
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeNotesRow(
        title: String,
        leftNotes: [String],
        rightNotes: [String]
    ) -> some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .top, spacing: 12) {
                makeNotesColumn(leftNotes)
                makeNotesColumn(rightNotes)
            }
        }
    }
    
    func makeNotesColumn(_ notes: [String]) -> some View {
        HStack(spacing: 10) {
            ForEach(notes, id: \.self) { note in
                VStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(.placeholderMedium))
                        .frame(width: 38, height: 38)
                    
                    Text(note)
                        .font(.caption)
                        .foregroundStyle(Color(.textSecondary))
                        .multilineTextAlignment(.center)
                        .frame(width: 48)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeImpressionSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle("Общее впечатление")
            
            HStack(spacing: 14) {
                makeImpressionCard("Глубокий, древесный, элегантный.")
                makeImpressionCard("Свежий, пряный, мужественный.")
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeImpressionCard(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(Color(.textPrimary))
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, minHeight: 72)
            .padding(.horizontal, 10)
            .background(Color(.rowBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
    
    func makePerformanceSection() -> some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                makeScoreColumn(
                    topTitle: "Стойкость",
                    topScore: "8/10",
                    topValue: 0.78,
                    bottomTitle: "Шлейф",
                    bottomScore: "9/10",
                    bottomValue: 0.88,
                    accentColor: Color(.pinkButton)
                )
                
                VStack {
                    Image(systemName: "hand.thumbsup")
                        .font(.headline)
                        .foregroundStyle(Color(.pinkButton))
                        .frame(width: 42, height: 42)
                        .background(Color(.surfacePrimary))
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(Color(.cardBorder), lineWidth: 1)
                        )
                    Spacer()
                }
                
                makeScoreColumn(
                    topTitle: "Стойкость",
                    topScore: "7/10",
                    topValue: 0.68,
                    bottomTitle: "Шлейф",
                    bottomScore: "8/10",
                    bottomValue: 0.76,
                    accentColor: Color(.zodiacPurple)
                )
            }
        }
        .padding(16)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeScoreColumn(
        topTitle: String,
        topScore: String,
        topValue: CGFloat,
        bottomTitle: String,
        bottomScore: String,
        bottomValue: CGFloat,
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            makeScoreRow(title: topTitle, score: topScore, value: topValue, color: accentColor)
            makeScoreRow(title: bottomTitle, score: bottomScore, value: bottomValue, color: accentColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func makeScoreRow(
        title: String,
        score: String,
        value: CGFloat,
        color: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                Spacer()
                
                Text(score)
                    .font(.headline)
                    .foregroundStyle(color)
            }
            
            RoundedRectangle(cornerRadius: 999, style: .continuous)
                .fill(color.opacity(0.45))
                .frame(width: 82 * value, height: 10)
        }
    }
    
    func makeSectionTitle(_ title: String) -> some View {
        HStack {
            Spacer()
            
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
                .foregroundStyle(Color(.textPrimary))
            
            Spacer()
            
            Image(systemName: "info.circle")
                .font(.headline)
                .foregroundStyle(Color(.textSecondary))
        }
    }
}
