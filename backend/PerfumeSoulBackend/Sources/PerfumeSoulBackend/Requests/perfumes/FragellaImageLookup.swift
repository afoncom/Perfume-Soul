import Foundation
import Vapor

struct FragellaFragrance: Decodable {
    let name: String
    let brand: String
    let imageURL: String?
    let concentration: String?

    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case brand = "Brand"
        case imageURL = "Image URL"
        case concentration = "OilType"
    }
}

enum FragellaImageLookup {
    static func lookup(client: any Client, apiKey: String?, brand: String, name: String, concentration: String?) async throws -> String? {
        guard let apiKey, !apiKey.isEmpty, name.count >= 3 else {
            return nil
        }
        var components = URLComponents(string: "https://api.fragella.com/api/v1/fragrances")
        components?.queryItems = [
            URLQueryItem(name: "search", value: name),
            URLQueryItem(name: "limit", value: "10")
        ]
        guard let url = components?.url else {
            return nil
        }
        let response = try await client.get(URI(string: url.absoluteString)) { request in
            request.headers.add(name: "x-api-key", value: apiKey)
        }
        guard response.status == .ok else {
            throw Abort(.badGateway, reason: "Image provider is unavailable.")
        }
        let matches = try response.content.decode([FragellaFragrance].self)
        return imageURL(in: matches, brand: brand, name: name, concentration: concentration)
    }

    static func imageURL(
        in matches: [FragellaFragrance],
        brand: String,
        name: String,
        concentration: String? = nil
    ) -> String? {
        let expectedBrand = normalized(brand)
        let expectedName = normalized(name)
        let match = matches.first { match in
            let matchBrand = normalized(match.brand)
            let brandMatches = matchBrand == expectedBrand
                || (expectedBrand == "dior" && matchBrand == "christian dior")
            let matchName = normalized(match.name)
            let unbrandedName = matchName.hasPrefix(expectedBrand + " ")
                ? String(matchName.dropFirst(expectedBrand.count + 1)) : matchName
            let concentrationMatches = concentration == nil || match.concentration == nil
                || normalized(concentration ?? "") == normalized(match.concentration ?? "")
            return brandMatches
                && (matchName == expectedName || unbrandedName == expectedName)
                && concentrationMatches
                && validImageURL(match.imageURL)
        }
        return match?.imageURL
    }

    private static func normalized(_ value: String) -> String {
        value.folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }

    private static func validImageURL(_ value: String?) -> Bool {
        guard let value, let url = URLComponents(string: value) else {
            return false
        }
        return url.scheme == "https" && url.host == "cdn.fragella.com"
            && url.path.hasPrefix("/images/") && url.user == nil && url.password == nil
    }
}
