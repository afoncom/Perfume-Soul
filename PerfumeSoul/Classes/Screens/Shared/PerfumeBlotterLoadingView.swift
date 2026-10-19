import SwiftUI

struct PerfumeBlotterLoadingView: View {
    let title: String
    var isCompact = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isAnimating = false

    var body: some View {
        VStack(spacing: isCompact ? 16 : 28) {
            HStack(spacing: 14) {
                blotter(height: 56, movement: 5, delay: 0)
                blotter(height: 80, movement: -6, delay: 0.12)
                blotter(height: 64, movement: 5, delay: 0.24)
            }
            .frame(height: 96)
            .accessibilityHidden(true)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.vertical, isCompact ? 12 : 40)
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
        .onAppear { isAnimating = !reduceMotion }
        .onChange(of: reduceMotion) { _, value in isAnimating = !value }
    }

    private func blotter(height: Double, movement: Double, delay: Double) -> some View {
        Rectangle()
            .fill(Color(.backgroundPrimary))
            .frame(width: 20, height: height)
            .overlay { Rectangle().strokeBorder(Color(.textPrimary), lineWidth: 1) }
            .offset(y: reduceMotion ? 0 : (isAnimating ? movement : -movement))
            .animation(
                reduceMotion ? nil : .easeInOut(duration: 1.1).repeatForever().delay(delay),
                value: isAnimating
            )
    }
}
