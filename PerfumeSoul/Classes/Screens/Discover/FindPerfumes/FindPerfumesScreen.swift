//
//  FindPerfumesScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct FindPerfumesScreen: View {
    @Bindable private var viewModel: FindPerfumesViewModel
    @FocusState private var focusedField: FindPerfumeField?
    private let presenter: FindPerfumesPresenter

    init(
        viewModel: FindPerfumesViewModel,
        presenter: FindPerfumesPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                makeHeaderView()
                makePerfumeFieldsSection()
                makeSearchResultsSection()
                makeHintCard()
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 120)
        }
        .background {
            Color(.backgroundPrimary).ignoresSafeArea()
        }
        .safeAreaInset(edge: .bottom) {
            makeFindButton()
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 8)
        }
        .alert(
            L10n.Common.Error.message,
            isPresented: $viewModel.isShowingValidationAlert,
            actions: {
                Button("OK", role: .cancel) {}
            },
            message: {
                Text(viewModel.validationMessage ?? "")
            }
        )
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension FindPerfumesScreen {
    private var currentSearchText: String {
        switch focusedField {
        case .first:
            viewModel.firstSearchText
        case .second:
            viewModel.secondSearchText
        case .third:
            viewModel.thirdSearchText
        case nil:
            ""
        }
    }

    private func makeHeaderView() -> some View {
        VStack(spacing: 10) {
            Text(L10n.Discover.FindSimilar.title)
                .font(.system(size: 28, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.titleText))
                .multilineTextAlignment(.center)

            Text(L10n.Discover.FindSimilar.headerSubtitle)
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 4)
    }

    private func makePerfumeFieldsSection() -> some View {
        VStack(spacing: 14) {
            makePerfumeField(
                title: L10n.Discover.FindSimilar.firstPerfumeTitle,
                placeholder: L10n.Discover.FindSimilar.firstPerfumeSubtitle,
                text: Binding(
                    get: { viewModel.firstSearchText },
                    set: { newValue in
                        viewModel.firstSearchText = newValue

                        Task {
                            await presenter.searchTextChanged(newValue, for: .first)
                        }
                    }
                ),
                field: .first
            )

            makePerfumeField(
                title: L10n.Discover.FindSimilar.secondPerfumeTitle,
                placeholder: L10n.Discover.FindSimilar.optionalSubtitle,
                text: Binding(
                    get: { viewModel.secondSearchText },
                    set: { newValue in
                        viewModel.secondSearchText = newValue

                        Task {
                            await presenter.searchTextChanged(newValue, for: .second)
                        }
                    }
                ),
                field: .second
            )

            makePerfumeField(
                title: L10n.Discover.FindSimilar.thirdPerfumeTitle,
                placeholder: L10n.Discover.FindSimilar.optionalSubtitle,
                text: Binding(
                    get: { viewModel.thirdSearchText },
                    set: { newValue in
                        viewModel.thirdSearchText = newValue

                        Task {
                            await presenter.searchTextChanged(newValue, for: .third)
                        }
                    }
                ),
                field: .third
            )
        }
    }

    private func makePerfumeField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        field: FindPerfumeField
    ) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(.surfaceOverlay))
                    .frame(width: 46, height: 46)

                Image(systemName: "bag")
                    .font(.headline)
                    .foregroundStyle(field == .first ? Color(.pinkButton) : Color(.textSecondary))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(.textPrimary))

                TextField(placeholder, text: text)
                    .focused($focusedField, equals: field)
                    .submitLabel(.done)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
            }

            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.title3)
                .foregroundStyle(Color(.textSecondary))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(Color(.surfacePrimary))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color(.cardBorder), lineWidth: 1)
        )
        .shadow(color: Color(.cardShadowSubtle), radius: 7, x: 0, y: 3)
        .onTapGesture {
            focusedField = field
        }
    }

    @ViewBuilder
    private func makeSearchResultsSection() -> some View {
        let shouldShowSection = (
            focusedField != nil
            && !currentSearchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        )
            || viewModel.isSearching
            || !viewModel.searchResults.isEmpty
            || viewModel.searchErrorMessage != nil

        if shouldShowSection {
            VStack(alignment: .leading, spacing: 12) {
                if viewModel.isSearching {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                } else if let searchErrorMessage = viewModel.searchErrorMessage {
                    Text(searchErrorMessage)
                        .font(.body)
                        .foregroundStyle(Color(.textSecondary))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else if viewModel.searchResults.isEmpty {
                    Text(L10n.SearchPerfume.emptyState)
                        .font(.body)
                        .foregroundStyle(Color(.textSecondary))
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.vertical, 20)
                } else {
                    ForEach(viewModel.searchResults) { perfume in
                        Button {
                            guard let currentField = focusedField else { return }

                            presenter.searchResultTapped(perfume, for: currentField)
                            focusedField = nil
                        } label: {
                            Text(perfume.name)
                                .font(.body)
                                .foregroundStyle(Color(.textPrimary))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(Color(.surfacePrimary))
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Color(.cardBorder), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private func makeHintCard() -> some View {
        HStack(spacing: 12) {
            Image(systemName: "sparkles")
                .font(.title3)
                .foregroundStyle(Color(.zodiacPurple))

            Text(L10n.Discover.FindSimilar.hint)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.purpleTable))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(.tableBorder), lineWidth: 1)
        )
    }

    private func makeFindButton() -> some View {
        Button {
            presenter.findSimilarPerfumesButtonTapped()
        } label: {
            Text(L10n.Discover.FindSimilar.button)
                .font(.system(size: 24, weight: .medium, design: .rounded))
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    LinearGradient(
                        colors: [
                            Color(.buttonShine),
                            Color(.pinkButton)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
        }
        .background(Color(.surfaceHighlight))
    }
}
