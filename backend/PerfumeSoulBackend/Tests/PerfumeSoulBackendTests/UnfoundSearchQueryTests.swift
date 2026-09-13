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
