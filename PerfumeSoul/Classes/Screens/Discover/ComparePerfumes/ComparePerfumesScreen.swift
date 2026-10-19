import SwiftUI

struct ComparePerfumesScreen: View {
    @Bindable private var viewModel: ComparePerfumesViewModel
    private let presenter: ComparePerfumesPresenter
    @State private var activeField: ComparePerfumeField?
    @State private var showsWear = false
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(viewModel: ComparePerfumesViewModel, presenter: ComparePerfumesPresenter) {
        self.viewModel = viewModel
        self.presenter = presenter
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    header
                    pairLayout {
                        selectionField(.left)
                        selectionField(.right)
                    }
                    comparisonContent.id("comparison")
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 36)
            }
            .onChange(of: viewModel.hasComparison) { _, hasComparison in
                if hasComparison {
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.25)) {
                        proxy.scrollTo("comparison", anchor: .top)
                    }
                }
            }
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !viewModel.hasComparison {
                PerfumePrimaryButton(title: L10n.ComparePerfumes.compareButton) {
                    Task { await presenter.compareTapped() }
                }
                .disabled(!viewModel.canCompare || viewModel.isLoading)
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(Color(.backgroundPrimary))
            }
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

    private var pairLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 20))
            : AnyLayout(HStackLayout(alignment: .top, spacing: 16))
    }

    private var header: some View {
        Text(L10n.ComparePerfumes.selectionDescription)
            .font(.body)
            .foregroundStyle(Color(.descriptionText))
            .fixedSize(horizontal: false, vertical: true)
    }

    private func selectionField(_ field: ComparePerfumeField) -> some View {
        Button {
            activeField = field
        } label: {
            VStack(alignment: .leading, spacing: 24) {
                HStack(alignment: .firstTextBaseline) {
                    Text(viewModel.symbol(for: field))
                        .font(.largeTitle.weight(.light))
                    Spacer(minLength: 8)
                    Image(systemName: viewModel.selectedPerfume(for: field) == nil ? "plus" : "arrow.up.right")
                        .font(.body)
                        .accessibilityHidden(true)
                }
                Text(viewModel.selectedPerfume(for: field)?.name ?? viewModel.title(for: field))
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
            .frame(maxWidth: .infinity, minHeight: 180, alignment: .topLeading)
            .background(Color(.textPrimary).opacity(field == .left ? 0.025 : 0.065))
            .overlay { Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1) }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(viewModel.isLoading)
        .accessibilityLabel(viewModel.selectionAccessibilityLabel(for: field))
    }

    @ViewBuilder private var comparisonContent: some View {
        if viewModel.isLoading {
            PerfumeBlotterLoadingView(title: L10n.ComparePerfumes.loadingMessage)
        } else if let errorMessage = viewModel.errorMessage {
            VStack(alignment: .leading, spacing: 24) {
                Text(errorMessage).font(.body).lineSpacing(4)
                PerfumePrimaryButton(title: L10n.ComparePerfumes.retryButton) {
                    Task { await presenter.retryTapped() }
                }
            }
        } else if let left = viewModel.leftPerfume, let right = viewModel.rightPerfume {
            VStack(alignment: .leading, spacing: 32) {
                Rectangle().fill(Color(.inputBorder)).frame(height: 1)
                pairLayout {
                    makePerfumeCard(
                        brand: left.brand,
                        name: left.name,
                        type: L10n.PerfumeDetails.Concentration.eauDeParfum
                    )
                    makePerfumeCard(
                        brand: right.brand,
                        name: right.name,
                        type: L10n.PerfumeDetails.Concentration.eauDeParfum
                    )
                }
                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        sectionButton(L10n.ComparePerfumes.notesTitle, wear: false)
                        sectionButton(L10n.ComparePerfumes.wearTitle, wear: true)
                    }
                } else {
                    Picker(L10n.ComparePerfumes.sectionPicker, selection: $showsWear) {
                        Text(L10n.ComparePerfumes.notesTitle).tag(false)
                        Text(L10n.ComparePerfumes.wearTitle).tag(true)
                    }
                    .pickerStyle(.segmented)
                }
                if showsWear {
                    wearSection(left: left, right: right)
                } else {
                    notesSection(left: left, right: right)
                }
            }
        }
    }

    private func sectionButton(_ title: String, wear: Bool) -> some View {
        Button { showsWear = wear } label: {
            HStack {
                Text(title).font(.body)
                Spacer()
                if showsWear == wear {
                    Image(systemName: "checkmark").accessibilityHidden(true)
                }
            }
            .padding(16)
            .background(Color(.textPrimary).opacity(showsWear == wear ? 0.08 : 0.025))
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(showsWear == wear ? .isSelected : [])
    }

    private func makePerfumeCard(
        brand: String,
        name: String,
        type: String
    ) -> some View {
        VStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.placeholderMedium))
                .frame(height: 156)
            
            VStack(spacing: 4) {
                Text(brand)
                    .font(.headline)
                    .foregroundStyle(Color(.textSecondary))
                
                Text(name)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color(.textPrimary))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(type)
                    .font(.footnote)
                    .foregroundStyle(Color(.textSecondary))
            }
            .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
    
    private func notesSection(left: ComparePerfume, right: ComparePerfume) -> some View {
        VStack(alignment: .leading, spacing: 28) {
            Text(L10n.ComparePerfumes.notesCaption)
                .font(.subheadline)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
            notesRow(
                title: L10n.PerfumeDetails.topNotesTitle,
                left: left.topNotes,
                right: right.topNotes
            )
            notesRow(
                title: L10n.PerfumeDetails.middleNotesTitle,
                left: left.middleNotes,
                right: right.middleNotes
            )
            notesRow(
                title: L10n.PerfumeDetails.baseNotesTitle,
                left: left.baseNotes,
                right: right.baseNotes
            )
        }
    }

    private func notesRow(title: String, left: [String], right: [String]) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(title.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1)
                .accessibilityAddTraits(.isHeader)
            pairLayout {
                notesColumn(field: .left, notes: left, otherNotes: right)
                notesColumn(field: .right, notes: right, otherNotes: left)
            }
            Rectangle().fill(Color(.inputBorder)).frame(height: 1)
        }
    }

    private func notesColumn(field: ComparePerfumeField, notes: [String], otherNotes: [String]) -> some View {
        let displayNotes = viewModel.displayNotes(notes)
        let otherDisplayNotes = viewModel.displayNotes(otherNotes)
        return VStack(alignment: .leading, spacing: 12) {
            Text(viewModel.title(for: field))
                .font(.caption)
                .foregroundStyle(Color(.descriptionText))
            if notes.isEmpty {
                Text(L10n.PerfumeDetails.emptyNotesPlaceholder).font(.subheadline)
            }
            ForEach(displayNotes, id: \.self) { note in
                let isShared = viewModel.isSharedNote(note, in: otherDisplayNotes)
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    if isShared {
                        Rectangle()
                            .fill(Color(.textPrimary))
                            .frame(width: 5, height: 5)
                            .accessibilityHidden(true)
                    }
                    Text(note)
                        .font(.body.weight(isShared ? .semibold : .regular))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .accessibilityLabel(isShared ? L10n.ComparePerfumes.sharedNote(note) : note)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private func wearSection(left: ComparePerfume, right: ComparePerfume) -> some View {
        VStack(alignment: .leading, spacing: 32) {
            wearRow(
                title: L10n.PerfumeDetails.longevityTitle,
                left: left.longevityScore,
                right: right.longevityScore
            )
            wearRow(
                title: L10n.PerfumeDetails.sillageTitle,
                left: left.sillageScore,
                right: right.sillageScore
            )
        }
    }

    private func wearRow(title: String, left: Int?, right: Int?) -> some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title.uppercased())
                .font(.caption.weight(.medium))
                .tracking(1)
                .accessibilityAddTraits(.isHeader)
            pairLayout {
                metric(field: .left, score: left)
                metric(field: .right, score: right)
            }
            Rectangle().fill(Color(.inputBorder)).frame(height: 1)
        }
    }

    private func metric(field: ComparePerfumeField, score: Int?) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(viewModel.title(for: field))
                .font(.caption)
                .foregroundStyle(Color(.descriptionText))
            Text(viewModel.scoreText(score))
                .font(.title.weight(.light))
                .monospacedDigit()
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle().fill(Color(.textPrimary).opacity(0.08))
                    Rectangle().fill(Color(.textPrimary))
                        .frame(width: geometry.size.width * viewModel.scoreFraction(score))
                }
            }
            .frame(height: 3)
            .accessibilityHidden(true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
    }
}
