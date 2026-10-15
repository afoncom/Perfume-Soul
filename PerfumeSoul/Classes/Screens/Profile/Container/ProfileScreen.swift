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
    @State private var selectedElement: ProfileElement?
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
                        makeProfileScreen(profile: profile, avatar: viewModel.avatar)
                            .padding(.horizontal, 16)
                        
                        makeMyNatalChart()
                            .padding(.horizontal, 16)
                        
                        makeElementBalance()
                            .padding(.horizontal, 16)

                        makePerfumeExpertiseLevel()
                            .padding(.horizontal, 16)

                        makeCabinetRow()
                            .padding(.horizontal, 16)

                        makePersonalPerfumesRow()
                            .padding(.horizontal, 16)

                        makeProfileDescriptionRow()
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

extension ProfileScreen {
    func makeCabinetRow() -> some View {
        Button {
            presenter.cabinetButtonTapped()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "archivebox")
                    .font(.headline)
                    .foregroundStyle(Color(.purpleIcon))
                    .frame(width: 46, height: 46)
                    .background(Color(.purpleTable).opacity(0.18))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Profile.Cabinet.title).font(.title3).fontWeight(.medium).foregroundStyle(Color(.textPrimary))
                    Text(L10n.Profile.Cabinet.subtitle).font(.footnote).foregroundStyle(Color(.textSecondary))
                }
                Spacer()
                Image(systemName: "chevron.right").foregroundStyle(Color(.textSecondary))
            }
            .padding(.horizontal, 16).padding(.vertical, 14)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay { RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(.cardBorder), lineWidth: 1) }
            .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    func makeProfileScreen(profile: Profile, avatar: ProfileAvatar) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(makeProfileAvatarGradient(colors: avatar.gradientColors))
                .frame(width: 74, height: 74)
                .overlay {
                    makeProfileAvatarInitials(avatar.initials, font: .title3)
                }
                .accessibilityHidden(true)
            
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
                    NatalChartRow(
                        color: Color(.natalSunSurface),
                        symbol: "sun.max.fill",
                        symbolColor: Color(.natalSunAccent),
                        title: L10n.Profile.NatalChart.sun,
                        placement: natalChart.sun
                    )

                    NatalChartRow(
                        color: Color(.natalMoonSurface),
                        symbol: "moon.fill",
                        symbolColor: Color(.natalMoonAccent),
                        title: L10n.Profile.NatalChart.moon,
                        placement: natalChart.moon
                    )

                    NatalChartRow(
                        color: Color(.natalAscendantSurface),
                        symbol: "circle.hexagongrid.fill",
                        symbolColor: Color(.pinkButton),
                        title: L10n.Profile.NatalChart.ascendant,
                        placement: natalChart.ascendant
                    )
                }
            } else {
                makeProfileCalculationStateView()
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
                let elementItems = makeElementBalanceItems(elementBalance: elementBalance)

                if elementItems.isEmpty {
                    Text(L10n.Profile.ElementBalance.unavailable)
                        .font(.footnote)
                        .foregroundStyle(Color(.descriptionText))
                        .frame(maxWidth: .infinity, alignment: .leading)
                } else {
                    makeElementBalanceBar(elementItems: elementItems)

                    LazyVGrid(
                        columns: Array(
                            repeating: GridItem(.flexible(), spacing: 4, alignment: .leading),
                            count: elementItems.count
                        ),
                        spacing: 8
                    ) {
                        ForEach(elementItems, id: \.element) { item in
                            makeElementItem(
                                element: item.element,
                                percent: "\(item.value)%",
                                title: item.title,
                                color: item.color
                            )
                        }
                    }
                }
            } else {
                makeProfileCalculationStateView()
            }
        }
        .padding(14)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
    }

    func makePersonalPerfumesRow() -> some View {
        Button {
            Task {
                await presenter.personalPerfumesButtonTapped()
            }
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
                    Text(L10n.PersonalPerfume.navigationTitle)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))
                    
                    Text(personalPerfumesSubtitle)
                        .font(.footnote)
                        .foregroundStyle(Color(.textSecondary))
                }
                
                Spacer()

                makePersonalPerfumesAccessory()
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
        .disabled(viewModel.isProfileCalculationLoading)
        .opacity(viewModel.isProfileCalculationLoading ? 0.65 : 1)
    }

    func makePersonalPerfumesAccessory() -> some View {
        Group {
            if viewModel.isProfileCalculationLoading {
                ProgressView()
                    .frame(width: 18, height: 18)
            } else if viewModel.needsProfileCalculationAction {
                Image(systemName: "arrow.clockwise")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
            } else {
                Image(systemName: "chevron.right")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textSecondary))
            }
        }
    }

    func makeProfileDescriptionRow() -> some View {
        Button {
            presenter.profileDescriptionButtonTapped()
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color(.pinkIconSurface))
                        .frame(width: 46, height: 46)

                    Image(systemName: "person.text.rectangle")
                        .font(.headline)
                        .foregroundStyle(Color(.pinkIcon))
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(L10n.Profile.PersonalityDescription.title)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))

                    Text(L10n.Profile.PersonalityDescription.subtitle)
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

                    Text(viewModel.perfumeExpertiseLevel.title)
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

            Text(viewModel.perfumeExpertiseLevel.description)
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
                            .frame(width: proxy.size.width * .init(viewModel.perfumeExpertiseProgress), height: 10)
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
        [profile.birthDate, profile.birthTime, profile.birthPlace]
            .filter { !$0.isEmpty }
            .joined(separator: " · ")
    }

    func makeZodiacInfo(profile: Profile) -> DailyHoroscope? {
        guard let sign = viewModel.profileCalculation?.natalChart.sun.sign.rawValue ?? profile.preferredZodiacSign else {
            return nil
        }

        return DailyHoroscope(sign: sign, energyOfDay: "")
    }

    func makeProfileAvatarGradient(colors: [ProfileAvatarColor]) -> LinearGradient {
        LinearGradient(
            colors: colors.map(makeProfileAvatarColor),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    func makeProfileAvatarColor(_ color: ProfileAvatarColor) -> Color {
        switch color {
        case .zodiacBlue:
            return Color(.zodiacBlue)
        case .zodiacPurple:
            return Color(.zodiacPurple)
        case .zodiacBrown:
            return Color(.zodiacBrown)
        case .zodiacPink:
            return Color(.zodiacPink)
        case .zodiacGray:
            return Color(.zodiacGray)
        case .avatarOcean:
            return Color(.avatarOcean)
        case .avatarTeal:
            return Color(.avatarTeal)
        case .avatarAmber:
            return Color(.avatarAmber)
        }
    }

    private func makeProfileAvatarInitials(_ initials: String, font: Font) -> some View {
        Text(initials)
            .font(font)
            .fontWeight(.semibold)
            .foregroundStyle(Color(.textOnAvatar))
            .lineLimit(1)
            .minimumScaleFactor(0.8)
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

    var personalPerfumesSubtitle: String {
        if viewModel.isProfileCalculationLoading {
            return L10n.Profile.PersonalPerfumes.loadingSubtitle
        }

        if viewModel.didFailProfileCalculation {
            return L10n.Profile.PersonalPerfumes.retrySubtitle
        }

        if viewModel.needsBirthDataForProfileCalculation {
            switch viewModel.profileCalculationState {
            case .missingBirthPlaceData:
                return L10n.Profile.Calculation.MissingBirthData.subtitle
            case .invalidBirthData:
                return L10n.Profile.Calculation.InvalidBirthData.subtitle
            case .idle, .loading, .loaded, .failed:
                break
            }
        }

        return L10n.Profile.PersonalPerfumes.subtitle
    }

}

// MARK: - Element Item

private enum ProfileElement: Hashable {
    case fire
    case earth
    case air
    case water
}

extension ProfileScreen {
    private func makeElementBalanceBar(
        elementItems: [(element: ProfileElement, value: Int, title: String, color: Color)]
    ) -> some View {
        GeometryReader { proxy in
            let width = Double(proxy.size.width)

            HStack(spacing: 0) {
                ForEach(elementItems, id: \.element) { item in
                    item.color
                        .frame(
                            width: width * .init(item.value) / 100
                        )
                }
            }
            .background(Color(.placeholderSoft))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .frame(height: 34)
    }

    private func makeElementBalanceItems(elementBalance: ElementBalance) -> [
        (element: ProfileElement, value: Int, title: String, color: Color)
    ] {
        [
            (.fire, elementBalance.fire, L10n.Profile.Element.fire, Color(.pinkButton)),
            (.earth, elementBalance.earth, L10n.Profile.Element.earth, Color(.zodiacMint)),
            (.air, elementBalance.air, L10n.Profile.Element.air, Color(.zodiacCyan)),
            (.water, elementBalance.water, L10n.Profile.Element.water, Color(.zodiacBlue))
        ]
        .filter { $0.value > 0 }
    }

    private func makeElementItem(
        element: ProfileElement,
        percent: String,
        title: String,
        color: Color
    ) -> some View {
        let isSelected = selectedElement == element

        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                selectedElement = isSelected ? nil : element
            }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Circle()
                    .fill(color)
                    .frame(width: 7, height: 7)

                Text(percent)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textPrimary))

                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color(.textSecondary))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .background(isSelected ? color.opacity(0.12) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}
