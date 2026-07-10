//
//  ProfileScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 15.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct ProfileScreen: View {
    @Bindable private var viewModel: ProfileViewModel
    private let presenter: ProfilePresenter
    
    init(
        viewModel: ProfileViewModel,
        presenter: ProfilePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ZStack {
            if let profile = viewModel.profile {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 10) {
                        makeProfileScreen(profile: profile)
                            .padding(.horizontal, 16)
                        
                        makeMyNatalChart()
                            .padding(.horizontal, 16)
                        
                        makeElementBalance()
                            .padding(.horizontal, 16)

                        makePerfumeExpertiseLevel()
                            .padding(.horizontal, 16)

                        makePersonalPerfumesRow()
                            .padding(.horizontal, 16)
                        
                        makeAddedNewProfiless()
                            .padding(.horizontal, 16)
                        
                        makeDeleteProfileAction()
                            .padding(.horizontal, 16)
                    }
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .alert(
            L10n.Profile.Actions.deleteAlertTitle,
            isPresented: $viewModel.isShowingDeleteProfileAlert
        ) {
            Button(L10n.Profile.Actions.cancelButton, role: .cancel) { }
            Button(L10n.Profile.Actions.deleteButton, role: .destructive) {
                Task {
                    await presenter.deleteProfile()
                }
            }
        } message: {
            Text(L10n.Profile.Actions.deleteAlertMessage)
        }
        .task {
            await presenter.onAppear()
        }
    }
}

private extension ProfileScreen {
    func makeProfileScreen(profile: Profile) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color(.placeholderStrong))
                .frame(width: 74, height: 74)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(profile.name)
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textPrimary))
                
                Text(makeProfileBirthInfo(profile: profile))
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)

                if let zodiacInfo = makeZodiacInfo(profile: profile) {
                    makeZodiacBadge(zodiacInfo: zodiacInfo)
                }
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }
    
    func makeMyNatalChart() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Profile.NatalChart.title)
                .font(.title3)
                .fontWeight(.medium)
            if let natalChart = viewModel.profileCalculation?.natalChart {
                VStack(spacing: 8) {
                    makeNatalChartRow(
                        color: Color(.natalSunSurface),
                        symbol: "sun.max.fill",
                        symbolColor: Color(.natalSunAccent),
                        title: L10n.Profile.NatalChart.sun,
                        value: makePlacementTitle(for: natalChart.sun)
                    )

                    makeNatalChartRow(
                        color: Color(.natalMoonSurface),
                        symbol: "moon.fill",
                        symbolColor: Color(.natalMoonAccent),
                        title: L10n.Profile.NatalChart.moon,
                        value: makePlacementTitle(for: natalChart.moon)
                    )

                    makeNatalChartRow(
                        color: Color(.natalAscendantSurface),
                        symbol: "circle.hexagongrid.fill",
                        symbolColor: Color(.pinkButton),
                        title: L10n.Profile.NatalChart.ascendant,
                        value: makePlacementTitle(for: natalChart.ascendant)
                    )
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeElementBalance() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Profile.ElementBalance.title)
                .font(.title3)
                .fontWeight(.medium)
            if let elementBalance = viewModel.profileCalculation?.elementBalance {
                makeElementBalanceBar(elementBalance: elementBalance)

                HStack {
                    makeElementItem(percent: "\(elementBalance.fire)%", title: L10n.Profile.Element.fire)
                    Spacer()
                    makeElementItem(percent: "\(elementBalance.earth)%", title: L10n.Profile.Element.earth)
                    Spacer()
                    makeElementItem(percent: "\(elementBalance.air)%", title: L10n.Profile.Element.air)
                    Spacer()
                    makeElementItem(percent: "\(elementBalance.water)%", title: L10n.Profile.Element.water)
                }
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    func makePersonalPerfumesRow() -> some View {
        Button {
            presenter.personalPerfumesButtonTapped()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.purpleTable).opacity(0.18))
                        .frame(width: 46, height: 46)
                    
                    Image(systemName: "sparkles")
                        .font(.headline)
                        .foregroundStyle(Color(.purpleIcon))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Personal Perfumes")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))
                    
                    Text("Open your curated fragrance selection.")
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(.cardBorder), lineWidth: 1)
            )
            .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    func makePerfumeExpertiseLevel() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color(.surfaceOverlay))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Image(systemName: "medal.star.fill")
                            .font(.title3)
                            .foregroundStyle(Color(.pinkButton))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Profile.Expertise.title)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))

                    Text(expertiseLevelTitle)
                        .font(.headline)
                        .foregroundStyle(Color(.pinkButton))
                }

                Spacer()

                Text("\(viewModel.totalCorrectQuizAnswers)")
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.surfaceOverlay))
                    .clipShape(Capsule())
            }

            Text(expertiseLevelDescription)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 8) {
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(Color(.placeholderSoft))
                            .frame(height: 10)

                        RoundedRectangle(cornerRadius: 999, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(.buttonShine),
                                        Color(.pinkButton)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * CGFloat(viewModel.perfumeExpertiseProgress), height: 10)
                    }
                }
                .frame(height: 10)

                HStack {
                    Text(L10n.Profile.Expertise.correctAnswersFormat(viewModel.totalCorrectQuizAnswers))
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))

                    Spacer()

                    if let answersToNextLevel = viewModel.answersToNextLevel {
                        Text(L10n.Profile.Expertise.nextLevelFormat(answersToNextLevel))
                            .font(.footnote)
                            .foregroundStyle(Color(.textSecondary))
                    } else {
                        Text(L10n.Profile.Expertise.maxLevel)
                            .font(.footnote)
                            .foregroundStyle(Color(.pinkButton))
                    }
                }
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeAddedNewProfiless() -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(L10n.Profile.Profiles.title)
                    .font(.title3)
                    .fontWeight(.medium)
                
                Spacer()
                
                Button(action: {
                    presenter.addedNewProfilesButtonTab()
                }) {
                    Image(systemName: "plus")
                        .font(.headline.weight(.medium))
                        .foregroundStyle(Color(.textSecondary))
                        .frame(width: 28, height: 28)
                }
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    makeAddedProfileItem(name: "Laura")
                    makeAddedProfileItem(name: "Alex")
                    makeAddedProfileItem(name: "Ada")
                }
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }
    
    func makeDeleteProfileAction() -> some View {
        Button {
            viewModel.isShowingDeleteProfileAlert = true
        } label: {
            Text(L10n.Profile.Actions.deleteButton)
                .font(.headline)
                .foregroundStyle(Color(.destructiveAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.destructiveSurface))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(.plain)
    }
    
    func makeProfileBirthInfo(profile: Profile) -> String {
        return [profile.birthDate, profile.birthTime, profile.birthPlace]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    func makeZodiacInfo(profile: Profile) -> DailyHoroscope? {
        let sign = viewModel.profileCalculation?.natalChart.sun.sign ?? profile.zodiacSign()
        guard let sign else {
            return nil
        }

        return DailyHoroscope(sign: sign, energyOfDay: "")
    }

    func makeZodiacBadge(zodiacInfo: DailyHoroscope) -> some View {
        HStack(spacing: 8) {
            Text(zodiacInfo.symbol)
                .font(.subheadline)

            Text(zodiacInfo.displayName)
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .foregroundStyle(zodiacInfo.iconColor)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(
            Capsule(style: .continuous)
                .fill(zodiacInfo.iconColor.opacity(0.14))
        )
    }

    var expertiseLevelTitle: String {
        switch viewModel.perfumeExpertiseLevel {
        case .novice:
            return L10n.Profile.Expertise.Level.novice
        case .noteExplorer:
            return L10n.Profile.Expertise.Level.noteExplorer
        case .accordExpert:
            return L10n.Profile.Expertise.Level.accordExpert
        case .fragranceAnalyst:
            return L10n.Profile.Expertise.Level.fragranceAnalyst
        case .perfumer:
            return L10n.Profile.Expertise.Level.perfumer
        }
    }

    var expertiseLevelDescription: String {
        switch viewModel.perfumeExpertiseLevel {
        case .novice:
            return L10n.Profile.Expertise.Description.novice
        case .noteExplorer:
            return L10n.Profile.Expertise.Description.noteExplorer
        case .accordExpert:
            return L10n.Profile.Expertise.Description.accordExpert
        case .fragranceAnalyst:
            return L10n.Profile.Expertise.Description.fragranceAnalyst
        case .perfumer:
            return L10n.Profile.Expertise.Description.perfumer
        }
    }

    func makePlacementTitle(for placement: ZodiacPlacement) -> String {
        let horoscope = DailyHoroscope(sign: placement.sign, energyOfDay: "")
        return "\(horoscope.displayName) \(horoscope.symbol)"
    }
}

//MARK: - Natal Chart Row

private extension ProfileScreen {
    func makeNatalChartRow(
        color: Color,
        symbol: String,
        symbolColor: Color,
        title: String,
        value: String
    ) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 42, height: 42)
                .overlay(
                    Image(systemName: symbol)
                        .font(.headline)
                        .foregroundColor(symbolColor)
                )
            
            HStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                
                Text(value)
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color(.textSecondary))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color(.rowBackground))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

//MARK: - Element Item

private extension ProfileScreen {
    func makeElementBalanceBar(elementBalance: ElementBalance) -> some View {
        GeometryReader { proxy in
            let width = proxy.size.width

            HStack(spacing: 0) {
                makeElementBalanceSegment(
                    color: Color(.pinkButton),
                    width: width * CGFloat(elementBalance.fire) / 100
                )
                makeElementBalanceSegment(
                    color: Color(.zodiacMint),
                    width: width * CGFloat(elementBalance.earth) / 100
                )
                makeElementBalanceSegment(
                    color: Color(.zodiacCyan),
                    width: width * CGFloat(elementBalance.air) / 100
                )
                makeElementBalanceSegment(
                    color: Color(.zodiacBlue),
                    width: width * CGFloat(elementBalance.water) / 100
                )
            }
            .background(Color(.placeholderSoft))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .frame(height: 34)
    }

    func makeElementBalanceSegment(color: Color, width: CGFloat) -> some View {
        color
            .frame(width: width)
    }

    func makeElementItem(percent: String, title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(percent)
                .font(.headline)
                .fontWeight(.medium)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.textSecondary))
        }
    }
}

//MARK: - Added Profile Item

private extension ProfileScreen {
    func makeAddedProfileItem(name: String) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(width: 92, height: 92)
            
            Text(name)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
        }
    }
}
