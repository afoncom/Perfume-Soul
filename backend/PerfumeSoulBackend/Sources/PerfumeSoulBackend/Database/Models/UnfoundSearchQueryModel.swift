import Fluent
import Foundation

final class UnfoundSearchQueryModel: Model, @unchecked Sendable {
    static let schema = "unfound_search_queries"

    @ID(custom: .id, generatedBy: .database)
    var id: Int?

    @Field(key: "query_text")
    var queryText: String

    @Field(key: "normalized_query")
    var normalizedQuery: String

    @Field(key: "search_context")
    var searchContext: String

    @Field(key: "occurrence_count")
    var occurrenceCount: Int

    @Timestamp(key: "first_seen_at", on: .create)
    var firstSeenAt: Date?

    @Timestamp(key: "last_seen_at", on: .update)
    var lastSeenAt: Date?

    init() { }

    init(queryText: String, normalizedQuery: String, searchContext: String) {
        self.queryText = queryText
        self.normalizedQuery = normalizedQuery
        self.searchContext = searchContext
        self.occurrenceCount = 1
    }
}
