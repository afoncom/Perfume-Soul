//
//  PerfumePrimaryButton.swift
//  PerfumeSoul
//

import SwiftUI

struct PerfumePrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(title)
                    .font(.body.weight(.medium))
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 8)

                Image(systemName: "arrow.right")
                    .font(.body.weight(.regular))
                    .accessibilityHidden(true)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 17)
            .frame(maxWidth: .infinity, minHeight: 56)
        }
        .buttonStyle(PerfumeButtonStyle())
    }
}

private struct PerfumeButtonStyle: ButtonStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(isEnabled ? Color(.backgroundPrimary) : Color(.textPrimary))
            .background(Color(.textPrimary).opacity(isEnabled ? 1 : 0.08))
            .opacity(isEnabled && configuration.isPressed ? 0.8 : 1)
            .scaleEffect(isEnabled && configuration.isPressed && !reduceMotion ? 0.985 : 1)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
