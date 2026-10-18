//
//  CalculationStateView.swift
//  PerfumeSoul
//
//  Created by afon.com on 14.10.2026.
//  Copyright © 2026 afon.com. All rights reserved.
//
import SwiftUI

struct CalculationStateView: View {
    private let title: String
    private let subtitle: String
    private let buttonTitle: String
    private var action: () -> Void
    
    init(
        title: String, subtitle: String, buttonTitle: String,
        action: @escaping () -> Void
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
}
