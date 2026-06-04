import Foundation

struct Perfume: Codable, Equatable {
    let name: String
}

enum PerfumeLoader {
    static func load() throws -> [Perfume] {
        let url = try resourceURL(for: "perfumesList")
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Perfume].self, from: data)
    }

    private static func resourceURL(for resourceName: String) throws -> URL {
        if let url = Bundle.module.url(forResource: resourceName, withExtension: "json") {
            return url
        }

        throw CocoaError(.fileNoSuchFile)
    }
}
