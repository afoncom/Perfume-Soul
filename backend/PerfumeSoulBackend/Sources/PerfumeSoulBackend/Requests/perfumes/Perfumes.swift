import Foundation

struct Perfumes: Codable, Equatable {
    let name: String
}

enum PerfumesLoader {
    static func load() throws -> [Perfumes] {
        let url = try resourceURL(for: "perfumesList")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Perfumes].self, from: data)
    }

    private static func resourceURL(for dateKey: String) throws -> URL {
        if let url = Bundle.module.url(forResource: dateKey, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
