import SwiftUI

struct CatalogPerfumeImage: View {
    let perfume: CatalogPerfume
    let loader: PerfumeImageLoader
    @State private var image: UIImage?

    init(perfume: CatalogPerfume, loader: PerfumeImageLoader) {
        self.perfume = perfume
        self.loader = loader
        _image = State(initialValue: loader.cachedImage(for: perfume))
    }

    var body: some View {
        Rectangle()
            .fill(Color(.placeholderSoft))
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .padding(8)
                }
            }
            .overlay { Rectangle().stroke(Color(.cardBorder), lineWidth: 1) }
            .accessibilityHidden(true)
            .task(id: perfume) {
                image = loader.cachedImage(for: perfume)
                guard image == nil else {
                    return
                }
                do {
                    let loaded = try await loader.image(for: perfume)
                    try Task.checkCancellation()
                    image = loaded
                } catch { /* Missing or failed photos retain the neutral placeholder. */ }
            }
    }
}
