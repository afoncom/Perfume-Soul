import SwiftUI

struct DiscoverScreen: View {
    @Bindable private var viewModel: DiscoverViewModel
    private let presenter: DiscoverPresenter
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .largeTitle) private var headingSize = 38.0

    init(viewModel: DiscoverViewModel, presenter: DiscoverPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 40) {
                quizSection
                comparisonSection
                similarSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 40)
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .foregroundStyle(Color(.textPrimary))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var quizSection: some View {
        VStack(alignment: .leading, spacing: 22) {
            caption("01", title: L10n.Screen.quizOfTheDay)
            Text(L10n.Discover.ScentArchetype.title)
                .font(.system(size: headingSize, weight: .semibold))
                .tracking(-1.4)
                .fixedSize(horizontal: false, vertical: true)

            if !dynamicTypeSize.isAccessibilitySize {
                Image(.discoverStudioPhoto)
                    .resizable()
                    .scaledToFit()
                    .accessibilityHidden(true)
            }

            Text(L10n.Discover.quizSubtitle)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            PerfumePrimaryButton(title: L10n.Discover.ScentArchetype.button) {
                presenter.quizOfTheDayButtonTapped()
            }
        }
    }

    private var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            rule
            caption("02", title: L10n.Discover.Compare.title)
            if !dynamicTypeSize.isAccessibilitySize {
                HStack(spacing: 1) {
                    comparisonLetter("A", isInverse: false)
                    comparisonLetter("B", isInverse: true)
                }
                .accessibilityHidden(true)
            }

            Text(L10n.Discover.compareHeadline)
                .font(.system(size: headingSize, weight: .medium))
                .tracking(-1.2)
                .fixedSize(horizontal: false, vertical: true)
            Text(L10n.Discover.Compare.description)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
            PerfumePrimaryButton(title: L10n.Discover.Compare.openButton) {
                presenter.comparePerfumesButtonTab()
            }
        }
    }

    private var similarSection: some View {
        VStack(alignment: .leading, spacing: 24) {
            rule
            caption("03", title: L10n.Discover.FindSimilar.title)
            HStack(alignment: .top, spacing: 20) {
                Text(L10n.Discover.similarHeadline)
                    .font(.system(size: headingSize, weight: .medium))
                    .tracking(-1.2)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !dynamicTypeSize.isAccessibilitySize {
                    Image(systemName: "arrow.triangle.branch")
                        .font(.system(size: 42, weight: .ultraLight))
                        .padding(.top, 8)
                        .accessibilityHidden(true)
                }
            }
            Text(L10n.Discover.FindSimilar.subtitle)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
            PerfumePrimaryButton(title: L10n.Discover.FindSimilar.button) {
                presenter.findPerfumesButtonTab()
            }
        }
    }

    private var rule: some View {
        Rectangle().fill(Color(.inputBorder)).frame(height: 1)
    }

    private func caption(_ number: String, title: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 16) {
            Text(number).monospacedDigit()
            Text(title.uppercased()).tracking(1)
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(Color(.descriptionText))
    }

    private func comparisonLetter(_ letter: String, isInverse: Bool) -> some View {
        Text(letter)
            .font(.system(size: 88, weight: .ultraLight))
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .foregroundStyle(isInverse ? Color(.backgroundPrimary) : Color(.textPrimary))
            .background(isInverse ? Color(.textPrimary) : Color(.textPrimary).opacity(0.04))
    }
}
