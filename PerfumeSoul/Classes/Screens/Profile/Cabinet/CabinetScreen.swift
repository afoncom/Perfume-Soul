//
//  CabinetScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.09.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct CabinetScreen: View {
    @Bindable private var viewModel: CabinetViewModel
    private let presenter: CabinetPresenter

    init(
        viewModel: CabinetViewModel,
        presenter: CabinetPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 18) {
                Text(L10n.Profile.Cabinet.header)
                    .font(.title3)
                    .italic()
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color(.textSecondary))
                    .padding(.horizontal, 28)

                switch viewModel.state {
                case .loading:
                    ProgressView().frame(maxWidth: .infinity, minHeight: 180)
                case .empty:
                    Text(L10n.Profile.Cabinet.empty)
                        .foregroundStyle(Color(.textSecondary))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, minHeight: 220)
                case let .content(perfumes):
                    LazyVStack(spacing: 10) {
                        ForEach(perfumes) { perfume in
                            HStack(spacing: 12) {
                                Button {
                                    presenter.perfumeTapped(perfume)
                                } label: {
                                    HStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color(.placeholderMedium))
                                            .frame(width: 58, height: 72)
                                            .overlay { Image(systemName: "bottle.fill").foregroundStyle(Color(.textSecondary)) }
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(perfume.brandName).font(.subheadline).foregroundStyle(Color(.textSecondary))
                                            Text(perfume.perfumeName).font(.title3).fontWeight(.medium).foregroundStyle(Color(.textPrimary))
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right").foregroundStyle(Color(.textSecondary))
                                    }
                                    .padding(12)
                                }
                                .buttonStyle(.plain)

                                Button {
                                    presenter.removePerfume(perfume)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundStyle(Color(.textSecondary))
                                        .frame(width: 44, height: 44)
                                }
                                .buttonStyle(.plain)
                            }
                            .background(Color(.surfacePrimary))
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay { RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(Color(.cardBorder), lineWidth: 1) }
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .onAppear {
            presenter.onAppear()
        }
    }
}
