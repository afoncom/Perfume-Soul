//
//  DayInPerfumeryScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DayInPerfumeryScreen: View {
    @Bindable private var viewModel: DayInPerfumeryViewModel
    private let presenter: DayInPerfumeryPresenter
    
    init(
        viewModel: DayInPerfumeryViewModel,
        presenter: DayInPerfumeryPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                makeHeaderView()
                makeImagePlaceholder()
                makeDescriptionView()
                makeDetailsCard()
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
    }
}

private extension DayInPerfumeryScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 8) {
            Text("Dior Diorissimo")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
            
            Text("Один из самых культовых ароматов Dior с нотой ландыша.")
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(.placeholderMedium))
            .frame(height: 220)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(Color(.pinkButton))
                    
                    Text("Diorissimo")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))
                }
            }
    }
    
    func makeDescriptionView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("12 мая 1957 года Дом Dior представил миру аромат Diorissimo — утончённый цветочный букет, вдохновлённый ландышем, любимым цветком Кристиана Диора.")
            
            Text("Парфюмер Эдмон Рудницка создал аромат, передающий нежность, свежесть и элегантность в одном флаконе.")
            
            Text("Этот аромат и сегодня остаётся одним из самых узнаваемых творений модного дома Dior.")
        }
        .font(.body)
        .foregroundStyle(Color(.textPrimary))
        .lineSpacing(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    func makeDetailsCard() -> some View {
        VStack(spacing: 16) {
            makeDetailRow(
                symbol: "calendar",
                title: "Дата события",
                subtitle: "12 мая 1957"
            )
            
            makeDetailRow(
                symbol: "sparkles",
                title: "Аромат",
                subtitle: "Diorissimo"
            )
            
            makeDetailRow(
                symbol: "person",
                title: "Парфюмер",
                subtitle: "Edmond Roudnitska"
            )
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeDetailRow(
        symbol: String,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.headline)
                .foregroundStyle(Color(.pinkButton))
                .frame(width: 28)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
            }
            Spacer()
        }
    }
}
