import Foundation
import Testing
@testable import PerfumeSoulBackend

@Test("Cache entry expires at its configured TTL")
func cacheEntryExpiresAtConfiguredTTL() {
    let createdAt = Date(timeIntervalSince1970: 1_000)
    let ttl = TimeInterval(300)

    #expect(!PerfumeProfileCacheExpiration.isExpired(
        createdAt: createdAt,
        ttl: ttl,
        now: Date(timeIntervalSince1970: 1_299)
    ))
    #expect(PerfumeProfileCacheExpiration.isExpired(
        createdAt: createdAt,
        ttl: ttl,
        now: Date(timeIntervalSince1970: 1_300)
    ))
}
