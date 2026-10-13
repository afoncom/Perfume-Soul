import SwiftUI

struct PerfumeSearchSheet: View {
    let title: String
    let results: [SearchPerfumeItem]
    let isSearching: Bool
    let errorMessage: String?
    let search: (String) async -> Void
    let select: (SearchPerfumeItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @FocusState private var isFocused: Bool
    @State private var query = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .accessibilityHidden(true)
                        TextField(L10n.Discover.FindSimilar.perfumePlaceholder, text: $query)
                            .font(.body)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .focused($isFocused)
                            .submitLabel(.search)
                            .onSubmit { isFocused = false }
                        if !query.isEmpty {
                            Button {
                                query = ""
                            } label: {
                                Image(systemName: "xmark")
                                    .frame(minWidth: 44, minHeight: 44)
                            }
                            .accessibilityLabel(L10n.Discover.Search.clear)
                        }
                    }
                    .padding(.leading, 16)
                    .padding(.trailing, query.isEmpty ? 16 : 0)
                    .frame(minHeight: 56)
                    .background(Color(.textPrimary).opacity(0.04))
                    .overlay { Rectangle().strokeBorder(Color(.inputBorder), lineWidth: 1) }

                    searchContent
                }
                .padding(24)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color(.backgroundPrimary))
            .foregroundStyle(Color(.textPrimary))
            .tint(Color(.textPrimary))
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(L10n.Discover.Search.close) { dismiss() }
                        .tint(Color(.textPrimary))
                }
            }
            .task(id: query) { await search(query) }
            .onAppear { isFocused = true }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder private var searchContent: some View {
        if query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            Text(L10n.Discover.Search.hint)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
                .lineSpacing(4)
        } else if isSearching {
            PerfumeBlotterLoadingView(title: L10n.Discover.Search.loading, isCompact: true)
        } else if let errorMessage {
            VStack(alignment: .leading, spacing: 20) {
                Text(errorMessage).font(.body)
                PerfumePrimaryButton(title: L10n.ComparePerfumes.retryButton) {
                    Task { await search(query) }
                }
            }
        } else if results.isEmpty {
            Text(L10n.SearchPerfume.emptyState)
                .font(.body)
                .foregroundStyle(Color(.descriptionText))
        } else {
            LazyVStack(spacing: 0) {
                ForEach(results) { perfume in
                    Button {
                        select(perfume)
                        dismiss()
                    } label: {
                        HStack(alignment: .firstTextBaseline, spacing: 16) {
                            Text(perfume.name)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Image(systemName: "arrow.up.left")
                                .font(.footnote)
                                .accessibilityHidden(true)
                        }
                        .padding(.vertical, 20)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    Rectangle().fill(Color(.inputBorder)).frame(height: 1)
                }
            }
        }
    }
}
