import Fluent
import Testing
import Vapor
import VaporTesting
import XCTFluent
@testable import PerfumeSoulBackend

struct PerfumeImageRouteTests {
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
    private var shouldFail = true

    func imageURL() throws -> String? {
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
