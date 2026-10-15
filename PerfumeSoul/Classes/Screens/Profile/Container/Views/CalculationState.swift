//
//  CalculationState.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.10.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import SwiftUI

struct CalculationState: View {
    @Bindable private var viewModel: ProfileViewModel
    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private var action: @escaping () -> Void
    
    init(
        title: String, subtitle: String, buttonTitle: String, action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.action = action
    }
    
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
            
            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            
            Button(action: action) {
                Text(buttonTitle)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(.textOnAccent))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.pinkButton))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
    }
    
    @ViewBuilder
    func makeProfileCalculationStateView() -> some View {
        switch viewModel.profileCalculationState {
        case .idle, .loading:
            ProgressView()
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 20)
        case .loaded:
            EmptyView()
        case .missingBirthPlaceData:
            makeProfileCalculationActionState(
                title: L10n.Profile.Calculation.MissingBirthData.title,
                subtitle: L10n.Profile.Calculation.MissingBirthData.subtitle,
                buttonTitle: L10n.Profile.Calculation.MissingBirthData.button
            ) {
                Task {
                    await presenter.completeBirthDataButtonTapped()
                }
            }
        case .invalidBirthData:
            makeProfileCalculationActionState(
                title: L10n.Profile.Calculation.InvalidBirthData.title,
                subtitle: L10n.Profile.Calculation.InvalidBirthData.subtitle,
                buttonTitle: L10n.Profile.Calculation.InvalidBirthData.button
            ) {
                Task {
                    await presenter.completeBirthDataButtonTapped()
                }
            }
        case .failed:
            makeProfileCalculationActionState(
                title: L10n.Profile.Calculation.Failed.title,
                subtitle: L10n.Profile.Calculation.Failed.subtitle,
                buttonTitle: L10n.Profile.Calculation.Failed.button
            ) {
                Task {
                    await presenter.retryProfileCalculationButtonTapped()
                }
            }
        }
    }
}
