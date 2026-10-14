//
//  DayInPerfumeryScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 16.03.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct DayInPerfumeryScreen: View {
    @Bindable private var viewModel: DayInPerfumeryViewModel
    private let presenter: DayInPerfumeryPresenter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 32
    @ScaledMetric(relativeTo: .largeTitle) private var dateSize = 48

    init(
        viewModel: DayInPerfumeryViewModel,
        presenter: DayInPerfumeryPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                PerfumeFlowHeader(section: L10n.Today.History.title, step: nil)

                makeHeader()
                makeImagePlaceholder()
                makeStory()
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .background(Color(.backgroundPrimary))
        .foregroundStyle(Color(.textPrimary))
        .preferredColorScheme(.light)
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension DayInPerfumeryScreen {
    private func makeHeader() -> some View {
        VStack(alignment: .leading, spacing: 24) {
            Text(viewModel.dateText)
                .font(
                    dynamicTypeSize.isAccessibilitySize
                        ? .title.weight(.light)
                        : .system(size: dateSize, weight: .light)
                )
                .tracking(-1.5)
                .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
                .minimumScaleFactor(dynamicTypeSize.isAccessibilitySize ? 1 : 0.7)
                .fixedSize(horizontal: false, vertical: true)

            Rectangle()
                .fill(Color(.inputBorder))
                .frame(height: 1)
                .accessibilityHidden(true)

            Text(viewModel.historyFact.perfumeName)
                .font(.system(size: headingSize, weight: .semibold))
                .tracking(-0.8)
                .fixedSize(horizontal: false, vertical: true)
                .accessibilityAddTraits(.isHeader)

            Text(viewModel.historyFact.shortStory)
                .font(.title3)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func makeImagePlaceholder() -> some View {
        // Reserved for the historical fragrance photograph.
        Rectangle()
            .fill(Color(.textPrimary).opacity(0.035))
            .aspectRatio(4.0 / 3.0, contentMode: .fit)
            .overlay {
                Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }

    private func makeStory() -> some View {
        Text(viewModel.historyFact.fullStory)
            .font(.body)
            .lineSpacing(7)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
