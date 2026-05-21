//
//  SearchPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 21.05.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct SearchPerfumeScreen: View {
    @Bindable private var viewModel: SearchPerfumeViewModel
    private let presenter: SearchPerfumePresenter
    
    init(
        viewModel: SearchPerfumeViewModel,
        presenter: SearchPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                makeSearchFields()
                makeSearchButton()
                makeResultsSection()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 20)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
    }
}

extension SearchPerfumeScreen {
    func makeSearchFields() -> some View {
        VStack(spacing: 14) {
            makeTextField(
                title: L10n.SearchPerfume.searchTextTitle,
                placeholder: L10n.SearchPerfume.searchTextPlaceholder,
                text: $viewModel.searchText
            )

            makeTextField(
                title: L10n.SearchPerfume.pageTitle,
                placeholder: L10n.SearchPerfume.pagePlaceholder,
                text: $viewModel.pageText,
                keyboardType: .numberPad
            )

            makeTextField(
                title: L10n.SearchPerfume.itemsPerPageTitle,
                placeholder: L10n.SearchPerfume.itemsPerPagePlaceholder,
                text: $viewModel.itemsPerPageText,
                keyboardType: .numberPad
            )
        }
    }

    func makeTextField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(.textPrimary))

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(Color(.surfacePrimary))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(.cardBorder), lineWidth: 1)
                )
        }
    }

    func makeSearchButton() -> some View {
        Button {
            Task {
                await presenter.searchButtonTapped()
            }
        } label: {
            Text(L10n.SearchPerfume.searchButton)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.textOnAccent))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color(.pinkButton))
                .clipShape(Capsule())
        }
        .disabled(viewModel.isLoading)
    }

    @ViewBuilder
    func makeResultsSection() -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(L10n.SearchPerfume.resultsTitle)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.textPrimary))

            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else if viewModel.perfumes.isEmpty, viewModel.hasSearched {
                Text(L10n.SearchPerfume.emptyState)
                    .font(.body)
                    .foregroundStyle(Color(.textSecondary))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(Array(viewModel.perfumes.enumerated()), id: \.offset) { _, perfume in
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
            }
        }
    }
}
