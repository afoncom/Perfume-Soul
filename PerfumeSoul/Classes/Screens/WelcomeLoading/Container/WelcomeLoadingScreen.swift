//
//  WelcomeLoadingScreen.swift
//  PerfumeSoul
//
//  Created by afon.com on 05.04.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//

import SwiftUI

struct WelcomeLoadingScreen: View {
    @Bindable private var viewModel: WelcomeLoadingViewModel
    private let presenter: WelcomeLoadingPresenter
    
    init(
        viewModel: WelcomeLoadingViewModel,
        presenter: WelcomeLoadingPresenter
    ) {
        self.viewModel = viewModel
        self.presenter = presenter
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)

            VStack(spacing: 8) {
                Text("Loading profile")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Checking saved profile to choose the start screen.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .task {
            await presenter.onTask()
        }
    }
}

private extension WelcomeLoadingScreen {
    
}
