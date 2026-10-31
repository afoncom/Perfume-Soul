import Testing
@testable import PerfumeSoulBackend

struct CatalogImageCacheTests {
    @Test("Concurrent and repeated requests perform one lookup")
    func coalescesLookups() async throws {
        let cache = CatalogImageCache()
        let counter = LookupCounter()
        async let first = try cache.imageURL(for: 1) { await counter.lookup() }
        async let second = try cache.imageURL(for: 1) { await counter.lookup() }
        let values = try await [first, second]
        #expect(values == ["https://cdn.fragella.com/images/1.jpg", "https://cdn.fragella.com/images/1.jpg"])
        let cached = try await cache.imageURL(for: 1) { await counter.lookup() }
        #expect(cached == "https://cdn.fragella.com/images/1.jpg")
        #expect(await counter.count == 1)
    }

    @Test("Temporary provider errors can be retried immediately")
    func retriesProviderFailure() async throws {
        let cache = CatalogImageCache()
        do {
            _ = try await cache.imageURL(for: 3) { throw LookupFailure.unavailable }
            Issue.record("Expected provider error")
        } catch LookupFailure.unavailable { }
        let result = try await cache.imageURL(for: 3) { "https://cdn.fragella.com/images/3.jpg" }
        #expect(result == "https://cdn.fragella.com/images/3.jpg")
    }

    @Test("Missing photos are cached too")
    func cachesMissingPhoto() async throws {
        let cache = CatalogImageCache()
        let first = try await cache.imageURL(for: 2) { nil }
        let second = try await cache.imageURL(for: 2) { "unexpected" }
        #expect(first == nil)
        #expect(second == nil)
    }
}

private actor LookupCounter {
    var count = 0

    func lookup() async -> String? {
        count += 1
        await Task.yield()
        return "https://cdn.fragella.com/images/1.jpg"
    }
}

private enum LookupFailure: Error { case unavailable }
