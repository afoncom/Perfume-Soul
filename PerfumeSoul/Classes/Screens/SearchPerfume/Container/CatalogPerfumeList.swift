import SwiftUI
import UIKit

struct CatalogPerfumeList: UIViewRepresentable {
    let perfumes: [CatalogPerfume]
    let savedIDs: Set<Int>
    let columns: Int
    let imageLoader: PerfumeImageLoader
    let isLoadingMore: Bool
    let errorMessage: String?
    let onOpen: (CatalogPerfume) -> Void
    let onSave: (CatalogPerfume) -> Void
    let onAppear: (CatalogPerfume) -> Void
    let onRetry: () -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = UIColor(resource: .backgroundPrimary)
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 280
        table.keyboardDismissMode = .interactive
        table.contentInset.bottom = 16
        table.register(UITableViewCell.self, forCellReuseIdentifier: "perfumes")
        table.dataSource = context.coordinator
        table.delegate = context.coordinator
        return table
    }

    func updateUIView(_ table: UITableView, context: Context) {
        let previous = context.coordinator.parent
        context.coordinator.parent = self
        if previous.perfumes != perfumes || previous.savedIDs != savedIDs || previous.columns != columns ||
            previous.isLoadingMore != isLoadingMore || previous.errorMessage != errorMessage {
            table.reloadData()
        }
    }

    static func dismantleUIView(_ table: UITableView, coordinator: Coordinator) {
        table.delegate = nil
        table.dataSource = nil
    }

    final class Coordinator: NSObject, UITableViewDataSource, UITableViewDelegate {
        var parent: CatalogPerfumeList

        init(_ parent: CatalogPerfumeList) { self.parent = parent }

        private var perfumeRowCount: Int {
            (parent.perfumes.count + parent.columns - 1) / parent.columns
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            perfumeRowCount + (parent.isLoadingMore || parent.errorMessage != nil ? 1 : 0)
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "perfumes", for: indexPath)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(resource: .backgroundPrimary)
            if indexPath.row >= perfumeRowCount {
                cell.contentConfiguration = UIHostingConfiguration {
                    VStack(alignment: .leading, spacing: 24) {
                        if self.parent.isLoadingMore {
                            ProgressView().frame(maxWidth: .infinity).padding(20)
                        }
                        if let error = self.parent.errorMessage {
                            Text(error).foregroundStyle(Color(.textSecondary))
                            PerfumePrimaryButton(title: L10n.PerfumeDetails.retryButton) { [weak self] in
                                self?.parent.onRetry()
                            }
                        }
                    }
                }
                .margins(.all, 24)
            } else {
                let start = indexPath.row * parent.columns
                let items = Array(parent.perfumes[start..<min(start + parent.columns, parent.perfumes.count)])
                let loader = parent.imageLoader
                let savedIDs = parent.savedIDs
                let columns = parent.columns
                cell.contentConfiguration = UIHostingConfiguration {
                    HStack(alignment: .top, spacing: 16) {
                        ForEach(items) { perfume in
                            CatalogPerfumeCard(
                                perfume: perfume,
                                isSaved: savedIDs.contains(perfume.id),
                                imageLoader: loader,
                                onOpen: { [weak self] in self?.parent.onOpen(perfume) },
                                onSave: { [weak self] in self?.parent.onSave(perfume) }
                            )
                            .id(perfume.id)
                        }
                        if items.count < columns {
                            Color.clear.frame(maxWidth: .infinity)
                        }
                    }
                    .foregroundStyle(Color(.textPrimary))
                }
                .margins(.horizontal, 24)
                .margins(.vertical, 16)
            }
            return cell
        }

        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            guard indexPath.row < perfumeRowCount else {
                return
            }
            let lastIndex = min((indexPath.row + 1) * parent.columns, parent.perfumes.count) - 1
            parent.onAppear(parent.perfumes[lastIndex])
        }
    }
}
