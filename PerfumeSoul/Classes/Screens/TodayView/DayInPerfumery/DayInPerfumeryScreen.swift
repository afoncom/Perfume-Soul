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
    
    init(
        viewModel: DayInPerfumeryViewModel,
        presenter: DayInPerfumeryPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                makeHeaderView()
                makeImagePlaceholder()
                makeDescriptionView()
            }
            .padding(.horizontal, 18)
            .padding(.top, 20)
            .padding(.bottom, 28)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await presenter.onAppear()
        }
    }
}

private extension DayInPerfumeryScreen {
    func makeHeaderView() -> some View {
        VStack(spacing: 8) {
            Text(viewModel.historyFacts.first?.namePerfume ?? "")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color(.textPrimary))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    func makeImagePlaceholder() -> some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(Color(.placeholderMedium))
            .frame(height: 220)
            .overlay {
                VStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.title)
                        .foregroundStyle(Color(.pinkButton))
                    
                    Text(viewModel.historyFacts.first?.image ?? "")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundStyle(Color(.textPrimary))
                }
            }
    }
    
    func makeDescriptionView() -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(viewModel.historyFacts.first?.fullStory ?? "")
                .fixedSize(horizontal: false, vertical: true)
        }
        .font(.body)
        .foregroundStyle(Color(.textPrimary))
        .lineSpacing(4)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
