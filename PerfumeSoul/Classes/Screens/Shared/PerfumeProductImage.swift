import SwiftUI

/// Image content only; the owning screen keeps its existing photo size and placeholder.
struct PerfumeProductImage: View {
    let perfumeID: Int?
    let imageURL: URL?
    let loader: PerfumeImageLoader
    @State private var image: UIImage?

    init(perfumeID: Int? = nil, imageURL: URL? = nil, loader: PerfumeImageLoader) {
        self.perfumeID = perfumeID
        self.imageURL = imageURL
        self.loader = loader
        _image = State(initialValue: Self.cachedImage(perfumeID: perfumeID, imageURL: imageURL, loader: loader))
    }

    var body: some View {
        Color.clear
            .overlay {
                if let image {
                    GeometryReader { geometry in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                    }
                    .padding(8)
                }
            }
            .clipped()
            .accessibilityHidden(true)
            .task(id: "\(perfumeID ?? 0):\(imageURL?.absoluteString ?? "")") {
                image = Self.cachedImage(perfumeID: perfumeID, imageURL: imageURL, loader: loader)
                guard image == nil else {
                    return
                }
                do {
                    let loaded: UIImage?
                    if let imageURL {
                        loaded = try await loader.image(for: imageURL)
                    } else if let perfumeID {
                        loaded = try await loader.image(for: perfumeID)
                    } else {
                        return
                    }
                    try Task.checkCancellation()
                    image = loaded
                } catch { /* Keep the screen's placeholder; a later appearance can retry. */ }
            }
    }

    private static func cachedImage(perfumeID: Int?, imageURL: URL?, loader: PerfumeImageLoader) -> UIImage? {
        if let imageURL {
            return loader.cachedImage(for: imageURL)
        }
        if let perfumeID {
            return loader.cachedImage(for: perfumeID)
        }
        return nil
    }
}
