//
//  CatalogBrandList.swift
//  PerfumeSoul
//
//  Created by afon.com on 18.10.2026.
//

import SwiftUI
import UIKit

/// UIKit supplies the native, draggable alphabet index on every supported iOS version.
struct CatalogBrandList: UIViewRepresentable {
    let sections: [CatalogBrandSection]
    let favoriteIDs: Set<Int>
    let onSelect: (CatalogBrand) -> Void
    let onFavorite: (CatalogBrand) -> Void

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UITableView {
        let table = UITableView(frame: .zero, style: .plain)
        table.dataSource = context.coordinator
        table.backgroundColor = UIColor(resource: .backgroundPrimary)
        table.separatorColor = UIColor(resource: .cardBorder)
        table.sectionIndexColor = UIColor(resource: .textPrimary)
        table.sectionIndexBackgroundColor = UIColor(resource: .backgroundPrimary)
        table.sectionIndexTrackingBackgroundColor = UIColor(resource: .placeholderSoft)
        table.sectionIndexMinimumDisplayRowCount = 10
        table.separatorInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 64
        table.keyboardDismissMode = .interactive
        table.register(UITableViewCell.self, forCellReuseIdentifier: "brand")
        return table
    }

    func updateUIView(_ table: UITableView, context: Context) {
        let previous = context.coordinator.parent
        context.coordinator.parent = self
        if previous.sections != sections || previous.favoriteIDs != favoriteIDs {
            table.reloadData()
        }
    }

    final class Coordinator: NSObject, UITableViewDataSource {
        var parent: CatalogBrandList

        init(_ parent: CatalogBrandList) { self.parent = parent }

        func numberOfSections(in tableView: UITableView) -> Int { parent.sections.count }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.sections[section].brands.count
        }

        func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
            parent.sections[section].title
        }

        func sectionIndexTitles(for tableView: UITableView) -> [String]? {
            parent.sections.map(\.title)
        }

        func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
            index
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "brand", for: indexPath)
            let brand = parent.sections[indexPath.section].brands[indexPath.row]
            let isFavorite = parent.favoriteIDs.contains(brand.id)
            cell.selectionStyle = .none
            cell.backgroundColor = UIColor(resource: .backgroundPrimary)
            cell.contentConfiguration = UIHostingConfiguration {
                HStack(spacing: 12) {
                    Button { self.parent.onSelect(brand) } label: {
                        Text(brand.name)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                            .contentShape(Rectangle())
                    }
                    Button { self.parent.onFavorite(brand) } label: {
                        Image(systemName: isFavorite ? "heart.fill" : "heart")
                            .frame(width: 44, height: 44)
                    }
                    .accessibilityLabel(isFavorite ? String(localized: "catalog.unfollowBrand") : String(localized: "catalog.followBrand"))
                    .accessibilityValue(brand.name)
                }
                .buttonStyle(.plain)
                .foregroundStyle(Color(.textPrimary))
            }
            .margins(.horizontal, 24)
            .margins(.vertical, 8)
            return cell
        }
    }
}
