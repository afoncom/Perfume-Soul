import Foundation
import Testing
@testable import PerfumeSoulBackend

@Test("Unfound search events normalize whitespace and case")
func unfoundSearchEventNormalizesQuery() throws {
    let event = try UnfoundSearchQueryRequest(
        query: "  SAUVAGE   Elixir ",
        context: "library"
    ).validatedEvent()

    #expect(event.normalizedQuery == "sauvage elixir")
    #expect(event.context == .library)
}

@Test("Unfound search rate limiter rejects the 101st request from an address")
func unfoundSearchRateLimiterEnforcesDailyLimit() async {
    let limiter = UnfoundSearchRateLimiter()
    let now = Date(timeIntervalSince1970: 1000)

    for _ in 0..<100 {
        #expect(await limiter.allows(ipAddress: "127.0.0.1", now: now))
    }

    let isAllowed = await limiter.allows(ipAddress: "127.0.0.1", now: now)
    #expect(!isAllowed)
}
