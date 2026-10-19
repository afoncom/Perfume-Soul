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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    private let presenter: ProfilePresenter

    init(viewModel: ProfileViewModel, presenter: ProfilePresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 36) {
                if let profile = viewModel.profile {
                    identity(name: profile.name)
                    collectionActions
                    natalProfile
                    expertise
                    Button(role: .destructive) {
                        viewModel.isShowingDeleteProfileAlert = true
                    } label: {
                        Text(L10n.Profile.Actions.deleteButton)
                            .font(.footnote)
                            .foregroundStyle(Color(.textSecondary))
                            .frame(minHeight: 44)
                    }
                    .buttonStyle(.plain)
                } else {
                    ProgressView().frame(maxWidth: .infinity, minHeight: 240)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .tint(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
        .alert(L10n.Profile.Actions.deleteAlertTitle, isPresented: $viewModel.isShowingDeleteProfileAlert) {
            Button(L10n.Profile.Actions.cancelButton, role: .cancel) { }
            Button(L10n.Profile.Actions.deleteButton, role: .destructive) {
                Task { await presenter.deleteProfile() }
            }
        } message: {
            Text(L10n.Profile.Actions.deleteAlertMessage)
        }
        .task { await presenter.onAppear() }
    }

    private func identity(name: String) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 20))
            : AnyLayout(HStackLayout(spacing: 20))
        return layout {
            Text(viewModel.avatar.initials)
                .font(.title2.weight(.medium))
                .frame(width: 72, height: 72)
                .background(Color(.placeholderSoft), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 8) {
                Text(name)
                    .font(.largeTitle.weight(.medium))
                    .tracking(-1)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                Text(viewModel.birthInfo)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var collectionActions: some View {
        VStack(spacing: 0) {
            PerfumePrimaryButton(title: L10n.Profile.Cabinet.title) {
                presenter.cabinetButtonTapped()
            }
            Button {
                Task { await presenter.personalPerfumesButtonTapped() }
            } label: {
                HStack(spacing: 16) {
                    Text(L10n.PersonalPerfume.navigationTitle)
                        .font(.body.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                    if viewModel.isProfileCalculationLoading {
                        ProgressView()
                    } else {
                        Image(systemName: "arrow.up.right").accessibilityHidden(true)
                    }
                }
                .padding(.vertical, 22)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isProfileCalculationLoading)
            rule
        }
    }

    private var natalProfile: some View {
        VStack(alignment: .leading, spacing: 20) {
            sectionTitle(L10n.Profile.NatalChart.title)
            if viewModel.profileCalculation != nil {
                VStack(spacing: 0) {
                    ForEach(viewModel.natalRows, id: \.title) { row in
                        valueRow(title: row.title, value: row.value)
                        rule
                    }
                }
                DisclosureGroup(L10n.Profile.ElementBalance.title) {
                    VStack(spacing: 16) {
                        ForEach(viewModel.elementRows, id: \.title) { row in
                            VStack(alignment: .leading, spacing: 8) {
                                valueRow(title: row.title, value: "\(row.value)%")
                                ProgressView(value: Double(row.value), total: 100)
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                    .padding(.top, 12)
                }
                .font(.subheadline)
            } else {
                calculationState
            }
            Button {
                presenter.profileDescriptionButtonTapped()
            } label: {
                HStack {
                    Text(L10n.Profile.PersonalityDescription.title)
                    Spacer(minLength: 12)
                    Image(systemName: "arrow.up.right").accessibilityHidden(true)
                }
                .font(.subheadline.weight(.medium))
                .frame(minHeight: 44)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }

    private var expertise: some View {
        VStack(alignment: .leading, spacing: 16) {
            sectionTitle(L10n.Profile.Expertise.title)
            Text(viewModel.expertiseTitle)
                .font(.title2.weight(.medium))
                .fixedSize(horizontal: false, vertical: true)
            ProgressView(value: viewModel.perfumeExpertiseProgress)
                .accessibilityLabel(L10n.Profile.Expertise.title)
                .accessibilityValue(viewModel.expertiseProgressText)
                .animation(reduceMotion ? nil : .easeOut(duration: 0.25), value: viewModel.perfumeExpertiseProgress)
            Text(viewModel.expertiseProgressText)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.placeholderSoft))
    }

    @ViewBuilder private var calculationState: some View {
        switch viewModel.profileCalculationState {
        case .idle, .loading:
            ProgressView().frame(maxWidth: .infinity, minHeight: 80)
        case .loaded:
            EmptyView()
        case .failed, .invalidBirthData, .missingBirthPlaceData:
            Text(viewModel.calculationMessage)
                .font(.subheadline)
                .foregroundStyle(Color(.textSecondary))
                .fixedSize(horizontal: false, vertical: true)
            PerfumePrimaryButton(title: viewModel.calculationActionTitle) {
                Task {
                    if viewModel.didFailProfileCalculation {
                        await presenter.retryProfileCalculationButtonTapped()
                    } else {
                        await presenter.completeBirthDataButtonTapped()
                    }
                }
            }
        }
    }

    private func sectionTitle(_ title: String) -> some View {
        Text(title.uppercased())
            .font(.caption.weight(.medium))
            .tracking(1.2)
            .fixedSize(horizontal: false, vertical: true)
            .accessibilityAddTraits(.isHeader)
    }

    private func valueRow(title: String, value: String) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 6))
            : AnyLayout(HStackLayout(alignment: .firstTextBaseline, spacing: 16))
        return layout {
            Text(title).foregroundStyle(Color(.textSecondary))
            if !dynamicTypeSize.isAccessibilitySize { Spacer(minLength: 0) }
            Text(value).fontWeight(.medium)
        }
        .font(.subheadline)
        .padding(.vertical, 10)
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityElement(children: .combine)
    }

    private var rule: some View {
        Rectangle().fill(Color(.cardBorder)).frame(height: 1)
    }
}
