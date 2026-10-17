import SwiftUI

struct FindPerfumesScreen: View {
    @Bindable private var viewModel: FindPerfumesViewModel
    private let presenter: FindPerfumesPresenter
    @State private var activeField: FindPerfumeField?
    @State private var visibleFieldCount = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(viewModel: FindPerfumesViewModel, presenter: FindPerfumesPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 32) {
                header
                VStack(spacing: 16) {
                    selectionField(.first)
                    if visibleFieldCount >= 2 { selectionField(.second) }
                    if visibleFieldCount >= 3 { selectionField(.third) }
                    if visibleFieldCount < 3 {
                        Button {
                            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                                visibleFieldCount += 1
                            }
                            activeField = visibleFieldCount == 2 ? .second : .third
                        } label: {
                            Label(L10n.Discover.FindSimilar.addPerfume, systemImage: "plus")
                                .font(.body)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.vertical, 16)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                VStack(alignment: .leading, spacing: 18) {
                    Rectangle().fill(Color(.inputBorder)).frame(height: 1)
                    Text(L10n.Discover.FindSimilar.hint)
                        .font(.subheadline)
                        .foregroundStyle(Color(.descriptionText))
                        .lineSpacing(4)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            PerfumePrimaryButton(title: L10n.Discover.FindSimilar.button) {
                presenter.findSimilarPerfumesButtonTapped()
            }
            .disabled(viewModel.firstSelectedPerfume == nil)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color(.backgroundPrimary))
        }
        .background(Color(.backgroundPrimary).ignoresSafeArea())
        .foregroundStyle(Color(.textPrimary))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $activeField, onDismiss: { presenter.cancelSearch() }) { field in
            PerfumeSearchSheet(
                title: viewModel.title(for: field),
                results: viewModel.searchResults,
                isSearching: viewModel.isSearching,
                errorMessage: viewModel.searchErrorMessage,
                search: { await presenter.searchTextChanged($0, for: field) },
                select: { presenter.searchResultTapped($0, for: field) }
            )
        }
        .alert(L10n.Common.Error.message, isPresented: $viewModel.isShowingValidationAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.validationMessage ?? "")
        }
    }

    private var header: some View {
        Text(L10n.Discover.FindSimilar.headerSubtitle)
            .font(.body)
            .foregroundStyle(Color(.descriptionText))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func selectionField(_ field: FindPerfumeField) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Button {
                activeField = field
            } label: {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .firstTextBaseline, spacing: 12) {
                        Text(viewModel.number(for: field)).monospacedDigit()
                        Text(viewModel.title(for: field).uppercased()).tracking(0.8)
                        Spacer(minLength: 0)
                        Image(systemName: viewModel.selectedPerfume(for: field) == nil ? "plus" : "arrow.up.right")
                            .accessibilityHidden(true)
                    }
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color(.descriptionText))

                    Text(viewModel.selectedPerfume(for: field)?.name ?? L10n.Discover.FindSimilar.perfumePlaceholder)
                        .font(.title3.weight(.medium))
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(22)
                .frame(maxWidth: .infinity, minHeight: 142, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if field != .first {
                Button {
                    presenter.removePerfume(for: field)
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.2)) {
                        visibleFieldCount -= 1
                    }
                } label: {
                    Label(L10n.Discover.FindSimilar.removePerfume, systemImage: "minus")
                        .font(.footnote)
                        .foregroundStyle(Color(.descriptionText))
                        .padding(.horizontal, 22)
                        .frame(minHeight: 44, alignment: .leading)
                }
                .buttonStyle(.plain)
                .padding(.bottom, 8)
            }
        }
        .background(Color(.textPrimary).opacity(0.025))
        .overlay { Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1) }
    }
}
