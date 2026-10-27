import CryptoKit
import Foundation

struct PerfumeImageLocation: Codable, Sendable {
    let url: URL?
    let expires: Date
}

/// File operations run off the main actor. Failure to write a cache never prevents display.
actor PerfumeImageDiskCache {
    private let session: URLSession
    private let directory: URL?
    private let fileManager = FileManager.default
    private let maximumBytes = 100 * 1024 * 1024
    private let maximumAge: TimeInterval = 7 * 24 * 60 * 60

    init(session: URLSession, directory: URL?) {
        self.session = session
        self.directory = directory
    }

    func location(for id: Int) -> PerfumeImageLocation? {
        guard let file = directory?.appendingPathComponent("location-\(id).json"),
            let data = try? Data(contentsOf: file),
            let location = try? JSONDecoder().decode(PerfumeImageLocation.self, from: data),
            location.expires > Date() else {
            return nil
        }
        return location
    }

    func store(_ location: PerfumeImageLocation, for id: Int) {
        guard let directory, let data = try? JSONEncoder().encode(location) else {
            return
        }
        do {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            try data.write(to: directory.appendingPathComponent("location-\(id).json"), options: .atomic)
            trim()
        } catch { /* A cache write is optional. */ }
    }

    func data(for url: URL) async throws -> Data {
        guard url.scheme?.lowercased() == "https", url.host != nil else {
            throw URLError(.unsupportedURL)
        }
        if let file = fileURL(for: url),
            let attributes = try? fileManager.attributesOfItem(atPath: file.path),
            let modified = attributes[.modificationDate] as? Date,
            Date().timeIntervalSince(modified) < maximumAge,
            let data = try? Data(contentsOf: file) {
            return data
        }
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = 30
        let (data, response) = try await session.data(for: request)
        guard let response = response as? HTTPURLResponse, (200..<300).contains(response.statusCode) else {
            throw URLError(.badServerResponse)
        }
        guard !data.isEmpty, data.count <= 10 * 1024 * 1024 else {
            throw URLError(.dataLengthExceedsMaximum)
        }
        if let directory, let file = fileURL(for: url) {
            do {
                try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
                try data.write(to: file, options: .atomic)
                trim()
            } catch { /* Cache storage is optional, including when the disk is full. */ }
        }
        return data
    }

    func remove(_ url: URL) {
        if let file = fileURL(for: url) { try? fileManager.removeItem(at: file) }
    }

    private func fileURL(for url: URL) -> URL? {
        let key = SHA256.hash(data: Data(url.absoluteString.utf8)).map { String(format: "%02x", $0) }.joined()
        return directory?.appendingPathComponent(key)
    }

    private func trim() {
        guard let directory else {
            return
        }
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: [.contentModificationDateKey, .fileSizeKey]
        ) else {
            return
        }
        let entries = files.compactMap { file -> (url: URL, date: Date, size: Int)? in
            guard let values = try? file.resourceValues(forKeys: [.contentModificationDateKey, .fileSizeKey]),
                let date = values.contentModificationDate, let size = values.fileSize else {
                return nil
            }
            return (file, date, size)
        }
        .sorted { $0.date < $1.date }
        var total = entries.reduce(0) { $0 + $1.size }
        for entry in entries where total > maximumBytes || Date().timeIntervalSince(entry.date) >= maximumAge {
            do {
                try fileManager.removeItem(at: entry.url)
                total -= entry.size
            } catch { continue }
        }
    }
}
