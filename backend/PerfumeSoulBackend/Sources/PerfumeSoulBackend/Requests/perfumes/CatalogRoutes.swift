import Fluent
import Vapor

struct CatalogRoutes: RouteCollection {
    private let imageCache = CatalogImageCache()
    func boot(routes: any RoutesBuilder) throws {
        let catalog = routes.grouped("catalog")
        catalog.get("brands", use: brands)
        catalog.get("perfumes", use: perfumes)
        catalog.get("perfumes", ":perfumeID", "image", use: image)
    }

    private func image(_ request: Request) async throws -> CatalogImageResponse {
        guard let id = request.parameters.get("perfumeID", as: Int.self), id > 0 else {
            throw Abort(.badRequest)
        }
        guard let perfume = try await PerfumeModel.query(on: request.db)
            .filter(\.$id == id)
            .with(\.$brand)
            .first() else {
            throw Abort(.notFound)
        }
        // Reuse the lookup from feature/added-one-imagePerfume; the API key stays on the server.
        let apiKey = Environment.get("FRAGELLA_API_KEY")
        guard let apiKey, !apiKey.isEmpty else {
            return CatalogImageResponse(imageURL: nil)
        }
        let brand = perfume.brand.name
        let name = perfume.perfumeName
        let concentration = perfume.concentration
        let client = request.client
        let url = try await imageCache.imageURL(for: id) {
            try await FragellaImageLookup.lookup(
                client: client, apiKey: apiKey, brand: brand, name: name, concentration: concentration
            )
        }
        return CatalogImageResponse(imageURL: url)
    }

    private func brands(_ request: Request) async throws -> [CatalogBrandResponse] {
        let brands = try await BrandModel.query(on: request.db)
            .join(PerfumeModel.self, on: \BrandModel.$id == \PerfumeModel.$brand.$id)
            .field(\.$id)
            .field(\.$name)
            .unique()
            .sort(\.$name)
            .all()
        return brands.compactMap { brand in
            brand.id.map { CatalogBrandResponse(id: $0, name: brand.name) }
        }
    }

    private func perfumes(_ request: Request) async throws -> CatalogPageResponse {
        let parameters = try request.query.decode(CatalogQuery.self)
        let limit = min(max(parameters.limit ?? 30, 1), 50)
        let offset = min(max(parameters.offset ?? 0, 0), 1_000_000)
        let search = (parameters.searchText ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard search.count <= 120 else {
            throw Abort(.badRequest, reason: "Search is too long.")
        }
        let query = PerfumeModel.query(on: request.db)
            .field(\.$id)
            .field(\.$perfumeName)
            .field(\.$brand.$id)
            .with(\.$brand)
            .join(parent: \.$brand)
            .sort(BrandModel.self, \.$name)
            .sort(\.$perfumeName)
            .sort(\.$id)
            .range(offset..<(offset + limit + 1))
        if let brandID = parameters.brandID {
            query.filter(\.$brand.$id == brandID)
        }
        if !search.isEmpty {
            let escaped = search.replacingOccurrences(of: "\\", with: "\\\\")
                .replacingOccurrences(of: "%", with: "\\%")
                .replacingOccurrences(of: "_", with: "\\_")
            query.group(.or) { group in
                group.filter(\.$perfumeName, .custom("ilike"), "%\(escaped)%")
                    .filter(BrandModel.self, \.$name, .custom("ilike"), "%\(escaped)%")
            }
        }
        let results = try await query.all()
        let items = results.prefix(limit).compactMap { perfume -> CatalogPerfumeResponse? in
            guard let id = perfume.id else {
                return nil
            }
            return CatalogPerfumeResponse(
                id: id,
                name: perfume.perfumeName,
                brand: perfume.brand.name,
                brandID: perfume.$brand.id
            )
        }
        return CatalogPageResponse(items: items, hasMore: results.count > limit)
    }
}

private struct CatalogQuery: Content {
    let searchText: String?
    let brandID: Int?
    let offset: Int?
    let limit: Int?
}

private struct CatalogBrandResponse: Content {
    let id: Int
    let name: String
}

private struct CatalogPerfumeResponse: Content {
    let id: Int
    let name: String
    let brand: String
    let brandID: Int
}

private struct CatalogPageResponse: Content {
    let items: [CatalogPerfumeResponse]
    let hasMore: Bool
}

private struct CatalogImageResponse: Content {
    let imageURL: String?
}
