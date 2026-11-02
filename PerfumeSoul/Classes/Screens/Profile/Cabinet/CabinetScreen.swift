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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    private let imageLoader: PerfumeImageLoader
    private let presenter: CabinetPresenter

    init(viewModel: CabinetViewModel, presenter: CabinetPresenter, imageLoader: PerfumeImageLoader) {
        self.viewModel = viewModel
        self.presenter = presenter
        self.imageLoader = imageLoader
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                Text(L10n.Profile.Cabinet.subtitle)
                    .font(.body)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)

                switch viewModel.state {
                case .loading:
                    ProgressView().frame(maxWidth: .infinity, minHeight: 180)
                case .empty:
                    VStack(alignment: .leading, spacing: 16) {
                        Image(systemName: "heart")
                            .font(.largeTitle.weight(.ultraLight))
                            .accessibilityHidden(true)
                        Text(L10n.Profile.Cabinet.empty)
                            .font(.title3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, minHeight: 220, alignment: .leading)
                    .background(Color(.placeholderSoft))
                case let .content(perfumes):
                    LazyVStack(spacing: 24) {
                        ForEach(perfumes) { perfume in
                            perfumeRow(perfume)
                            Rectangle().fill(Color(.cardBorder)).frame(height: 1)
                        }
                    }
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
        .onAppear { presenter.onAppear() }
    }

    private func perfumeRow(_ perfume: PerfumeCollectionPerfume) -> some View {
        let layout = dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 16))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 20))
        return VStack(alignment: .leading, spacing: 12) {
            Button {
                presenter.perfumeTapped(perfume)
            } label: {
                layout {
                    Rectangle()
                        .fill(Color(.placeholderSoft))
                        .frame(width: 96, height: 96)
                        .overlay {
                            PerfumeProductImage(perfumeID: perfume.id, imageURL: perfume.imageURL, loader: imageLoader)
                        }
                        .overlay { Rectangle().stroke(Color(.cardBorder), lineWidth: 1) }
                        .accessibilityHidden(true)
                    VStack(alignment: .leading, spacing: 8) {
                        Text(perfume.brandName.uppercased())
                            .font(.caption.weight(.semibold))
                            .tracking(0.8)
                        Text(perfume.perfumeName)
                            .font(.title3.weight(.medium))
                        Image(systemName: "arrow.up.right")
                            .font(.subheadline)
                            .padding(.top, 4)
                            .accessibilityHidden(true)
                    }
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Button {
                presenter.removePerfume(perfume)
            } label: {
                Label(String(localized: "catalog.unsave"), systemImage: "heart.fill")
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
                    .frame(minHeight: 44)
            }
            .buttonStyle(.plain)
            .accessibilityValue(perfume.perfumeName)
        }
    }
}
