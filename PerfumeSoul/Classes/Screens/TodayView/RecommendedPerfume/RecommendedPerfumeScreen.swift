//
//  RecommendedPerfumeScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 07.09.2026.
//

import SwiftUI

struct RecommendedPerfumeScreen: View {
    @Bindable private var viewModel: RecommendedPerfumeViewModel
    private let presenter: RecommendedPerfumePresenter

    init(
        viewModel: RecommendedPerfumeViewModel,
        presenter: RecommendedPerfumePresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(L10n.Today.Recommended.title).font(.title3).fontWeight(.medium)
            Text(L10n.Today.Recommended.subtitle)
                .font(.footnote)
                .foregroundStyle(Color(.textSecondary))
            switch viewModel.state {
            case .loading:
                ProgressView().frame(maxWidth: .infinity, minHeight: 110)
            case .empty:
                EmptyView()
            case let .content(perfumes):
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(perfumes) { perfume in
                            VStack(alignment: .leading, spacing: 6) {
                                Button { presenter.perfumeTapped(perfume) } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        RoundedRectangle(cornerRadius: 16, style: .continuous).fill(Color(.placeholderMedium)).frame(width: 84, height: 96)
                                        Text(perfume.brandName).font(.subheadline).foregroundStyle(Color(.textPrimary)).lineLimit(1)
                                        Text(perfume.perfumeName).font(.caption).foregroundStyle(Color(.textSecondary)).lineLimit(1)
                                    }
                                }.buttonStyle(.plain)
                                Button { presenter.savePerfume(perfume) } label: {
                                    Image(systemName: "heart").foregroundStyle(Color(.pinkButton)).frame(maxWidth: .infinity, alignment: .trailing)
                                }.buttonStyle(.plain)
                            }
                            .padding(10).frame(width: 104, alignment: .leading).background(Color(.surfacePrimary)).clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }.padding(.vertical, 4)
            }
        }
        .task { await presenter.resolve() }
    }
}
