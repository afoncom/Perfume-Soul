//
//  CalculationScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 26.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct CalculationScreen: View {
    @Bindable private var viewModel: CalculationViewModel
    private let presenter: CalculationPresenter
    @FocusState private var focusedField: Field?
    
    init(
        viewModel: CalculationViewModel,
        presenter: CalculationPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 28) {
                makeHeaderView()
                makeFormCard()
                makeContinueButton()
            }
            .padding(.horizontal, 20)
            .padding(.top, 36)
            .padding(.bottom, 24)
        }
        .background(Color(.backgroundPrimary))
        .scrollDismissesKeyboard(.interactively)
    }
}

private extension CalculationScreen {
    enum Field {
        case name
        case birthPlace
    }
}

private extension CalculationScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 12) {
            Text(L10n.Screen.calculationCreateProfile)
                .font(.largeTitle)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
            
            Text(L10n.Calculation.subtitle)
                .font(.title3)
                .foregroundStyle(Color(.textSecondary))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(.horizontal, 12)
    }
    
    func makeFormCard() -> some View {
        VStack(alignment: .leading, spacing: 20) {
            makeNameField()
            makeBirthDateField()
            makeBirthTimeField()
            makeBirthPlaceField()
        }
        .padding(22)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: Color(.cardShadowSoft), radius: 18, x: 0, y: 8)
    }
    
    func makeNameField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Calculation.nameTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "person")
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                TextField(L10n.Calculation.namePlaceholder, text: $viewModel.firstName)
                    .focused($focusedField, equals: .name)
                    .submitLabel(.next)
                    .font(.title3)
                    .foregroundStyle(Color(.textPrimary))
                    .textInputAutocapitalization(.words)
                    .onSubmit {
                        focusedField = .birthPlace
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
    
    func makeBirthDateField() -> some View {
        makePickerField(
            title: L10n.Calculation.birthDateTitle,
            systemImage: "calendar",
            iconColor: Color(.textPrimary)
        ) {
            DatePicker(
                "",
                selection: $viewModel.birthDate,
                displayedComponents: .date
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
    }
    
    func makeBirthTimeField() -> some View {
        makePickerField(
            title: L10n.Calculation.birthTimeTitle,
            systemImage: "clock",
            iconColor: Color(.textPrimary)
        ) {
            DatePicker(
                "",
                selection: $viewModel.birthTime,
                displayedComponents: .hourAndMinute
            )
            .labelsHidden()
            .datePickerStyle(.compact)
        }
    }
    
    func makeBirthPlaceField() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(L10n.Calculation.birthPlaceTitle)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: "location")
                    .font(.headline)
                    .foregroundStyle(Color(.textPrimary))
                
                TextField(L10n.Calculation.birthPlacePlaceholder, text: $viewModel.birthPlace)
                    .focused($focusedField, equals: .birthPlace)
                    .submitLabel(.done)
                    .font(.title3)
                    .foregroundStyle(Color(.textPrimary))
                    .textInputAutocapitalization(.words)
                    .textContentType(.addressCity)
                    .autocorrectionDisabled()
                    .onChange(of: viewModel.birthPlace) { _, newValue in
                        if viewModel.selectedBirthPlace?.displayName != newValue {
                            viewModel.selectedBirthPlace = nil
                        }
                    }
                    .task(id: viewModel.birthPlace) {
                        try? await Task.sleep(for: .seconds(0.5))
                        guard focusedField == .birthPlace && !Task.isCancelled else { return }
                        await presenter.birthPlaceDidChange(viewModel.birthPlace)
                    }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.inputBorder), lineWidth: 1)
            )
            
            if focusedField == .birthPlace, !viewModel.birthPlaceCompletions.isEmpty {
                VStack(spacing: 0) {
                    ForEach(Array(viewModel.birthPlaceCompletions.prefix(5).enumerated()), id: \.offset) { index, completion in
                        Button {
                            focusedField = nil
                            Task {
                                await presenter.birthPlaceCompletionTapped(completion)
                            }
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(completion.title)
                                    .font(.headline)
                                    .foregroundStyle(Color(.textPrimary))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                if !completion.subtitle.isEmpty {
                                    Text(completion.subtitle)
                                        .font(.footnote)
                                        .foregroundStyle(Color(.textSecondary))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(.plain)
                        
                        if index < min(viewModel.birthPlaceCompletions.count, 5) - 1 {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.surfacePrimary))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(.inputBorder), lineWidth: 1)
                )
            }
        }
    }
    
    //MARK: - Continue Button
    func makeContinueButton() -> some View {
        Button {
            presenter.continueButtonTapped()
        } label: {
            Text(L10n.Common.continueButton)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.pinkButton))
                .clipShape(Capsule())
        }
        .disabled(!viewModel.isContinueEnabled)
        .opacity(viewModel.isContinueEnabled ? 1 : 0.6)
        .shadow(color: Color(.buttonShadow), radius: 12, x: 0, y: 6)
    }
    
    //MARK: - Display info view
    func makePickerField<Content: View>(
        title: String,
        systemImage: String,
        iconColor: Color,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.title3)
                .fontWeight(.medium)
            
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(iconColor)
                
                content()
                    .font(.title3)
                    .tint(Color(.textPrimary))
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .background(Color(.surfacePrimary))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color(.inputBorder), lineWidth: 1)
            )
        }
    }
}
