import Foundation

/// Coalesces provider lookups and remembers missing images as well as successful matches.
actor CatalogImageCache {
    private struct Entry {
        let url: String?
        let expires: Date
    }
    private var entries: [Int: Entry] = [:]
    private var pending: [Int: Task<String?, any Error>] = [:]

    func imageURL(for id: Int, lookup: @escaping @Sendable () async throws -> String?) async throws -> String? {
        if let entry = entries[id], entry.expires > Date() {
            return entry.url
        }
        if let task = pending[id] {
            return try await task.value
        }
        let task = Task { try await lookup() }
        pending[id] = task
        defer { pending[id] = nil }
        let url = try await task.value
        if entries.count >= 1000 {
            entries = entries.filter { $0.value.expires > Date() }
            if entries.count >= 1000, let oldest = entries.min(by: { $0.value.expires < $1.value.expires }) {
                entries[oldest.key] = nil
            }
        }
        entries[id] = Entry(url: url, expires: Date().addingTimeInterval(url == nil ? 3600 : 7 * 24 * 3600))
        return url
    }
}
