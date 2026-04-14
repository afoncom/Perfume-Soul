//
//  PersonalPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 12.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct PersonalPerfumeScreen: View {
    @Bindable private var viewModel: PersonalPerfumeViewModel
    private let presenter: PersonalPerfumePresenter

    init(
        viewModel: PersonalPerfumeViewModel,
        presenter: PersonalPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                makeHeaderView()
                makeSectionsView()
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 120)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.white
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
        .safeAreaInset(edge: .bottom) {
            makeContinueButton()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
    }
}

private extension PersonalPerfumeScreen {
    func makeSectionsView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            makePerfumeSection(
                title: "Luxury Picks",
                perfumes: [
                    ("Initio", "Oud for Greatness"),
                    ("Kilian", "Angels' Share"),
                    ("Tom Ford", "Soleil Blanc")
                ],
                description: "Oud, saffron, and patchouli create a deep, mysterious aura."
            )

            makePerfumeSection(
                title: "Daily Picks",
                perfumes: [
                    ("Chanel", "Coco Mademoiselle"),
                    ("Dior", "Sauvage"),
                    ("Byredo", "Mojave Ghost")
                ],
                description: "Fresh spices and amberwood suit your bold, confident vibe."
            )

            makePerfumeSection(
                title: "Affordable Picks",
                perfumes: [
                    ("Montblanc", "Explorer"),
                    ("Zara", "Vibrant Leather"),
                    ("Lattafa", "Khamrah")
                ],
                description: "Bergamot and warm woods give a refined effect with an easy mood."
            )
        }
    }

    func makeHeaderView() -> some View {
        VStack(spacing: 8) {
            Text("Your Personal Scents")
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.82))
                .multilineTextAlignment(.center)

            Text("Discover your curated fragrance selection.")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.45))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 8)
        .padding(.bottom, 8)
    }

    func makePerfumeSection(
        title: String,
        perfumes: [(name: String, subtitle: String)],
        description: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(size: 22, weight: .medium, design: .rounded))
                .foregroundStyle(Color.black.opacity(0.82))

            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    ForEach(Array(perfumes.enumerated()), id: \.offset) { _, perfume in
                        makePerfumeItem(name: perfume.name, subtitle: perfume.subtitle)
                    }
                }

                Text(description)
                    .font(.system(size: 16, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
            .background(Color.purpleTable)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.white.opacity(0.85), lineWidth: 1)
            )
        }
    }

    func makePerfumeItem(name: String, subtitle: String) -> some View {
        VStack(spacing: 10) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white)
                .frame(height: 108)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.black.opacity(0.04), lineWidth: 1)
                )

            VStack(spacing: 4) {
                Text(name)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.82))
                    .multilineTextAlignment(.center)

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular, design: .rounded))
                    .foregroundStyle(Color.black.opacity(0.45))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .top)
    }

    func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text("Continue")
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.18),
                            .pinkButton.opacity(0.82)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .background(Color.white.opacity(0.08))
    }
}
