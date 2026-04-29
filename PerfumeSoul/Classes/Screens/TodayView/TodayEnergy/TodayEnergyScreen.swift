//
//  TodayEnergyScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct TodayEnergyScreen: View {
    @Bindable private var viewModel: TodayEnergyViewModel
    private let presenter: TodayEnergyPresenter
    
    init(
        viewModel: TodayEnergyViewModel,
        presenter: TodayEnergyPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makePersonalSection()
                makeHoroscopeSection()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(Color(.backgroundPrimary))
        .navigationTitle("Энергия дня")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await presenter.onAppear()
        }
    }
}

private extension TodayEnergyScreen {
    func makePersonalSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Для вас")
                .font(.title3)
                .fontWeight(.medium)
            
            makeInfoCard(
                icon: "♏",
                iconColor: Color(.pinkButton),
                title: "Скорпион",
                subtitle: "Сегодня твои эмоции глубже и интенсивнее."
            )
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeHoroscopeSection() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Гороскопы на сегодня")
                .font(.title3)
                .fontWeight(.medium)
            
            VStack(spacing: 10) {
                makeInfoCard(
                    icon: "♈",
                    iconColor: Color(.pinkButton),
                    title: "Овен",
                    subtitle: "День активных действий и решительных шагов"
                )
                
                makeInfoCard(
                    icon: "♉",
                    iconColor: Color(.zodiacMint),
                    title: "Телец",
                    subtitle: "Стабильная и заботливая энергия"
                )
                
                makeInfoCard(
                    icon: "♊",
                    iconColor: Color(.zodiacOrange),
                    title: "Близнецы",
                    subtitle: "Сегодня любопытные и общительные вибрации"
                )
                
                makeInfoCard(
                    icon: "♋",
                    iconColor: Color(.zodiacBlue).opacity(0.7),
                    title: "Рак",
                    subtitle: "Сентиментальное и уютное настроение"
                )
                
                makeInfoCard(
                    icon: "♌",
                    iconColor: Color(.zodiacOrange).opacity(0.85),
                    title: "Лев",
                    subtitle: "Яркое и уверенное проявление себя"
                )
                
                makeInfoCard(
                    icon: "♍",
                    iconColor: Color(.zodiacBrown).opacity(0.7),
                    title: "Дева",
                    subtitle: "Собранное и практичное состояние"
                )
                
                makeInfoCard(
                    icon: "♎",
                    iconColor: Color(.zodiacPink).opacity(0.75),
                    title: "Весы",
                    subtitle: "Естественное стремление к гармонии"
                )
                
                makeInfoCard(
                    icon: "♐",
                    iconColor: Color(.zodiacPurple).opacity(0.75),
                    title: "Стрелец",
                    subtitle: "Свобода, движение и желание пробовать новое"
                )
                
                makeInfoCard(
                    icon: "♑",
                    iconColor: Color(.zodiacGray).opacity(0.85),
                    title: "Козерог",
                    subtitle: "Собранность, дисциплина и внимание к целям"
                )
                
                makeInfoCard(
                    icon: "♒",
                    iconColor: Color(.zodiacCyan).opacity(0.8),
                    title: "Водолей",
                    subtitle: "Свежие идеи, независимость и нестандартный взгляд"
                )
                
                makeInfoCard(
                    icon: "♓",
                    iconColor: Color(.zodiacBlue).opacity(0.55),
                    title: "Рыбы",
                    subtitle: "Интуитивное состояние, мягкость и чувствительность"
                )
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeInfoCard(
        icon: String,
        iconColor: Color,
        title: String,
        subtitle: String
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 42, height: 42)
                
                Text(icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
    }
}
