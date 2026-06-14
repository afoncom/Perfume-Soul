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
                makeNotesSection()
                makeWearSection()
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
    
    func makeNotesSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle("Пирамида нот")
            
            HStack(alignment: .top, spacing: 12) {
                makePerfumeNotesCard(
                    name: "Oud Wood",
                    accentColor: Color(.pinkButton),
                    topNotes: ["Кардамон", "Перец", "Палисандр", "Бергамот", "Лаванда"],
                    middleNotes: ["Уд", "Сандал", "Ветивер", "Сычуанский перец", "Пачули"],
                    baseNotes: ["Амбра", "Бобы тонка", "Ваниль", "Амброксан", "Кедр", "Лабданум"]
                )
                
                makePerfumeNotesCard(
                    name: "Sauvage",
                    accentColor: Color(.zodiacPurple),
                    topNotes: ["Бергамот", "Перец"],
                    middleNotes: ["Лаванда", "Герань", "Ветивер", "Пачули"],
                    baseNotes: ["Амброксан", "Кедр", "Лабданум"]
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
    
    func makePerfumeNotesCard(
        name: String,
        accentColor: Color,
        topNotes: [String],
        middleNotes: [String],
        baseNotes: [String]
    ) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Capsule()
                    .fill(accentColor.opacity(0.22))
                    .frame(width: 48, height: 6)
                
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .lineLimit(2)
            }
            
            makeNotesGroup(
                title: "Верхние",
                notes: topNotes,
                accentColor: accentColor
            )
            
            makeNotesGroup(
                title: "Средние",
                notes: middleNotes,
                accentColor: accentColor
            )
            
            makeNotesGroup(
                title: "Базовые",
                notes: baseNotes,
                accentColor: accentColor
            )
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    func makeNotesGroup(
        title: String,
        notes: [String],
        accentColor: Color
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(.textPrimary))
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(notes, id: \.self) { note in
                    makeNoteRow(
                        note: note,
                        accentColor: accentColor
                    )
                }
            }
        }
    }
    
    func makeNoteRow(
        note: String,
        accentColor: Color
    ) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Circle()
                .fill(accentColor.opacity(0.75))
                .frame(width: 8, height: 8)
                .padding(.top, 4)
            
            Text(note)
                .font(.footnote)
                .foregroundStyle(Color(.textPrimary))
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func makeWearSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            makeSectionTitle("На коже")
            
            HStack(alignment: .top, spacing: 12) {
                makeWearCard(
                    brand: "Tom Ford",
                    name: "Oud Wood",
                    accentColor: Color(.pinkButton),
                    metrics: [
                        ("Стойкость", "8/10"),
                        ("Шлейф", "9/10")
                    ]
                )
                
                makeWearCard(
                    brand: "Dior",
                    name: "Sauvage",
                    accentColor: Color(.zodiacPurple),
                    metrics: [
                        ("Стойкость", "7/10"),
                        ("Шлейф", "8/10")
                    ]
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
    
    func makeWearCard(
        brand: String,
        name: String,
        accentColor: Color,
        metrics: [(String, String)]
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(brand)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
                
                Text(name)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .lineLimit(2)
            }
            
            VStack(spacing: 10) {
                ForEach(metrics, id: \.0) { metric in
                    makeWearRow(
                        title: metric.0,
                        score: metric.1,
                        accentColor: accentColor
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .padding(14)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
    
    func makeWearRow(
        title: String,
        score: String,
        accentColor: Color
    ) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color(.textPrimary))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            
            Spacer(minLength: 8)
            
            Text(score)
                .font(.caption.weight(.semibold))
                .foregroundStyle(accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(accentColor.opacity(0.14))
                .clipShape(Capsule())
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
