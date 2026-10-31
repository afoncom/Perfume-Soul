import SwiftUI

struct CatalogPerfumeImage: View {
    let perfume: CatalogPerfume
    let loader: PerfumeImageLoader

    var body: some View {
        Rectangle()
            .fill(Color(.placeholderSoft))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                PerfumeProductImage(perfumeID: perfume.id, imageURL: perfume.imageURL, loader: loader)
            }
            .overlay { Rectangle().stroke(Color(.cardBorder), lineWidth: 1) }
            .accessibilityHidden(true)
    }
}
