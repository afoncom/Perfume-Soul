import SwiftUI

struct CatalogPerfumeCard: View {
    let perfume: CatalogPerfume
    let isSaved: Bool
    let imageLoader: PerfumeImageLoader
    let onOpen: () -> Void
    let onSave: () -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: 10) {
                CatalogPerfumeImage(perfume: perfume, loader: imageLoader)
                    .id(perfume.id)
                Text(perfume.brand.uppercased())
                    .font(.caption.weight(.semibold))
                    .tracking(0.8)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 4)
                Text(perfume.name)
                    .font(.subheadline)
                    .foregroundStyle(Color(.textSecondary))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .topTrailing) {
            Button(action: onSave) {
                Image(systemName: isSaved ? "heart.fill" : "heart")
                    .font(.body)
                    .contentTransition(reduceMotion ? .identity : .symbolEffect(.replace))
                    .frame(width: 44, height: 44)
                    .background(Color(.backgroundPrimary))
            }
            .buttonStyle(.plain)
            .padding(6)
            .accessibilityLabel(isSaved ? String(localized: "catalog.unsave") : String(localized: "catalog.save"))
            .accessibilityValue(perfume.name)
            .transaction { if reduceMotion { $0.animation = nil } }
        }
    }
}
