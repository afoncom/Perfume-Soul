import UIKit

/// Shared by the catalog module, rather than created for each reused cell.
@MainActor
final class PerfumeImageLoader {
    private let memory = NSCache<NSURL, UIImage>()
    private let disk: PerfumeImageDiskCache
    private let resolveImageURL: ((Int) async throws -> URL?)?
    private var locations: [Int: PerfumeImageLocation] = [:]
    private var locationTasks: [Int: Task<URL?, Error>] = [:]
    private var pending: [URL: Task<UIImage, Error>] = [:]

    init(
        session: URLSession = .shared,
        cacheDirectory: URL? = PerfumeImageLoader.defaultCacheDirectory,
        resolveImageURL: ((Int) async throws -> URL?)? = nil
    ) {
        self.resolveImageURL = resolveImageURL
        disk = PerfumeImageDiskCache(session: session, directory: cacheDirectory)
        memory.totalCostLimit = 32 * 1024 * 1024
    }

    nonisolated static var defaultCacheDirectory: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("PerfumeImages", isDirectory: true)
    }

    func cachedImage(for url: URL) -> UIImage? {
        memory.object(forKey: url as NSURL)
    }

    func cachedImage(for perfume: CatalogPerfume) -> UIImage? {
        guard let url = perfume.imageURL ?? locations[perfume.id]?.url else {
            return nil
        }
        return cachedImage(for: url)
    }

    func image(for perfume: CatalogPerfume) async throws -> UIImage? {
        let url: URL?
        if let known = perfume.imageURL {
            url = known
        } else if let location = locations[perfume.id], location.expires > Date() {
            url = location.url
        } else if let task = locationTasks[perfume.id] {
            url = try await task.value
        } else if let resolveImageURL {
            let task = Task { [disk] in
                if let stored = await disk.location(for: perfume.id) {
                    return stored.url
                }
                let resolved = try await resolveImageURL(perfume.id)
                let location = PerfumeImageLocation(
                    url: resolved, expires: Date().addingTimeInterval(resolved == nil ? 300 : 7 * 24 * 3600)
                )
                await disk.store(location, for: perfume.id)
                return resolved
            }
            locationTasks[perfume.id] = task
            defer { locationTasks[perfume.id] = nil }
            url = try await task.value
            locations[perfume.id] = PerfumeImageLocation(
                url: url, expires: Date().addingTimeInterval(url == nil ? 300 : 7 * 24 * 3600)
            )
        } else {
            return nil
        }
        guard let url else {
            return nil
        }
        return try await image(for: url)
    }

    func image(for url: URL) async throws -> UIImage {
        if let image = cachedImage(for: url) {
            return image
        }
        if let task = pending[url] {
            return try await task.value
        }
        // A disappearing cell cancels its own task, not the shared request. Other
        // cells still receive the result, and scrolling back can use the cache.
        let task = Task { [disk] in
            let data = try await disk.data(for: url)
            guard let original = UIImage(data: data),
                let image = await original.byPreparingThumbnail(ofSize: CGSize(width: 600, height: 600)) else {
                await disk.remove(url)
                throw URLError(.cannotDecodeContentData)
            }
            memory.setObject(image, forKey: url as NSURL, cost: image.cgImage.map { $0.bytesPerRow * $0.height } ?? data.count)
            return image
        }
        pending[url] = task
        defer { pending[url] = nil }
        return try await task.value
    }
}
