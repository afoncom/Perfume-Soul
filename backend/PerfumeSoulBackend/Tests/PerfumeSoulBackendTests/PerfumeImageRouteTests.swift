import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct PerfumeImageRouteTests {
    @Test("Both image endpoints reuse the same successful lookup", arguments: [false, true])
    func endpointsSharePhotoCache(catalogFirst: Bool) async throws {
        try await expectSharedLookup(catalogFirst: catalogFirst, imageURL: Self.expectedURL)
    }

    @Test("Both image endpoints reuse a successful missing-photo lookup", arguments: [false, true])
    func endpointsShareMissingPhotoCache(catalogFirst: Bool) async throws {
        try await expectSharedLookup(catalogFirst: catalogFirst, imageURL: nil)
    }

    @Test("A provider failure through either endpoint can recover through the other", arguments: [false, true])
    func endpointsShareRecovery(catalogFirst: Bool) async throws {
        let database = ArrayTestDatabase()
        for _ in 0..<3 { appendPerfume(to: database) }
        let provider = RecoveringPhotoProvider()
        let first = catalogFirst ? "/catalog/perfumes/1/image" : "/perfumes/1/image"
        let second = catalogFirst ? "/perfumes/1/image" : "/catalog/perfumes/1/image"

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { _, _, _ in try await provider.imageURL() }
            try await app.testing().test(.GET, first) { response in
                #expect(response.status == .serviceUnavailable)
            }
            for path in [second, first] {
                try await app.testing().test(.GET, path) { response in
                    #expect(response.status == .ok)
                    let image = try JSONDecoder().decode(ImageResponse.self, from: Data(response.body.string.utf8))
                    #expect(image.imageURL == Self.expectedURL)
                }
            }
            #expect(await provider.calls == 2)
        }
    }

    private static let expectedURL = "https://cdn.fragella.com/images/dior-sauvage.jpg"

    private func expectSharedLookup(catalogFirst: Bool, imageURL: String?) async throws {
        let database = ArrayTestDatabase()
        for _ in 0..<2 { appendPerfume(to: database) }
        let provider = CountingPhotoProvider(url: imageURL)
        let paths = ["/perfumes/1/image", "/catalog/perfumes/1/image"]

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { brand, name, concentration in
                #expect(brand == "Dior")
                #expect(name == "Sauvage")
                #expect(concentration == nil)
                return await provider.imageURL()
            }
            for path in catalogFirst ? Array(paths.reversed()) : paths {
                try await app.testing().test(.GET, path) { response in
                    #expect(response.status == .ok)
                    let image = try JSONDecoder().decode(ImageResponse.self, from: Data(response.body.string.utf8))
                    #expect(image.imageURL == imageURL)
                }
            }
            #expect(await provider.calls == 1)
        }
    }

    @Test("Photo provider failure leaves database details available")
    func failingPhotoProvider() async throws {
        let database = ArrayTestDatabase()
        appendPerfume(to: database)
        appendPerfume(to: database)
        database.append([])
        database.append([])

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { _, _, _ in throw Abort(.serviceUnavailable) }

            try await app.testing().test(.GET, "/perfumes/1/image") { response in
                #expect(response.status == .serviceUnavailable)
            }
            try await app.testing().test(.GET, "/perfumes/1/notes") { response in
                #expect(response.status == .ok)
                let details = try JSONDecoder().decode(PerfumeNotesResponse.self, from: Data(response.body.string.utf8))
                #expect(details.perfumeName == "Sauvage")
                #expect(details.brand == "Dior")
            }
        }
    }

    @Test("A recovered provider returns the photo on the next request while details stay available")
    func photoRecoversAfterProviderFailure() async throws {
        let database = ArrayTestDatabase()
        for _ in 0..<2 {
            appendPerfume(to: database)
            appendPerfume(to: database)
            database.append([])
            database.append([])
        }
        let provider = RecoveringPhotoProvider()

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { _, _, _ in try await provider.imageURL() }

            try await app.testing().test(.GET, "/perfumes/1/image") { response in
                #expect(response.status == .serviceUnavailable)
            }
            try await expectDetailsAvailable(app: app)
            try await app.testing().test(.GET, "/perfumes/1/image") { response in
                #expect(response.status == .ok)
                let image = try JSONDecoder().decode(ImageResponse.self, from: Data(response.body.string.utf8))
                #expect(image.imageURL == "https://cdn.fragella.com/images/dior-sauvage.jpg")
            }
            try await expectDetailsAvailable(app: app)
        }
    }

    @Test("A successful lookup without a photo still returns HTTP 200")
    func missingPhotoIsSuccessful() async throws {
        let database = ArrayTestDatabase()
        appendPerfume(to: database)

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { _, _, _ in nil }
            try await app.testing().test(.GET, "/perfumes/1/image") { response in
                #expect(response.status == .ok)
                let image = try JSONDecoder().decode(ImageResponse.self, from: Data(response.body.string.utf8))
                #expect(image.imageURL == nil)
            }
        }
    }

    @Test("Database details finish while the photo provider is still suspended", .timeLimit(.minutes(1)))
    func delayedPhotoProvider() async throws {
        let database = ArrayTestDatabase()
        appendPerfume(to: database)
        appendPerfume(to: database)
        database.append([])
        database.append([])
        let provider = DelayedPhotoProvider()

        try await withApp { app in
            app.databases.use(database.configuration, as: .psql)
            try routes(app) { _, _, _ in await provider.imageURL() }
            let photo = Task {
                try await app.testing().test(.GET, "/perfumes/1/image") { response in
                    #expect(response.status == .ok)
                    let image = try JSONDecoder().decode(ImageResponse.self, from: Data(response.body.string.utf8))
                    #expect(image.imageURL == "https://cdn.fragella.com/images/dior-sauvage.jpg")
                }
            }
            await provider.waitUntilStarted()
            do {
                try await app.testing().test(.GET, "/perfumes/1/notes") { response in
                    #expect(response.status == .ok)
                    let details = try JSONDecoder().decode(PerfumeNotesResponse.self, from: Data(response.body.string.utf8))
                    #expect(details.perfumeName == "Sauvage")
                    #expect(details.imageURL == nil)
                }
            } catch {
                await provider.release()
                _ = try? await photo.value
                throw error
            }
            await provider.release()
            _ = try await photo.value
        }
    }

    private func appendPerfume(to database: ArrayTestDatabase) {
        database.append([PerfumeModel(id: 1, perfumeName: "Sauvage", brandID: 1)])
        database.append([BrandModel(id: 1, name: "Dior")])
    }

    private func expectDetailsAvailable(app: Application) async throws {
        try await app.testing().test(.GET, "/perfumes/1/notes") { response in
            #expect(response.status == .ok)
            let details = try JSONDecoder().decode(PerfumeNotesResponse.self, from: Data(response.body.string.utf8))
            #expect(details.perfumeName == "Sauvage")
            #expect(details.brand == "Dior")
        }
    }
}

private struct ImageResponse: Decodable {
    let imageURL: String?
}

private actor RecoveringPhotoProvider {
    private(set) var calls = 0
    private var shouldFail = true

    func imageURL() throws -> String? {
        calls += 1
        if shouldFail {
            shouldFail = false
            throw Abort(.serviceUnavailable)
        }
        return "https://cdn.fragella.com/images/dior-sauvage.jpg"
    }
}

private actor DelayedPhotoProvider {
    private var imageContinuation: CheckedContinuation<String?, Never>?
    private var startedContinuation: CheckedContinuation<Void, Never>?

    func imageURL() async -> String? {
        await withCheckedContinuation { continuation in
            imageContinuation = continuation
            startedContinuation?.resume()
            startedContinuation = nil
        }
    }

    func waitUntilStarted() async {
        guard imageContinuation == nil else {
            return
        }
        await withCheckedContinuation { startedContinuation = $0 }
    }

    func release() {
        imageContinuation?.resume(returning: "https://cdn.fragella.com/images/dior-sauvage.jpg")
        imageContinuation = nil
    }
}

private actor CountingPhotoProvider {
    private(set) var calls = 0
    let url: String?

    init(url: String?) {
        self.url = url
    }

    func imageURL() -> String? {
        calls += 1
        return url
    }
}
