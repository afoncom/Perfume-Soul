import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application) throws {
    // Uncomment this if you want to serve files from /Public.
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    guard let databaseURL = Environment.get("DATABASE_URL") else {
        throw DatabaseConfigurationError.missingDatabaseURL
    }

    app.databases.use(try .postgres(url: databaseURL), as: .psql)
    app.migrations.add(AddPerfumeProfileMetadataMigration())
    app.migrations.add(AddPerfumeMarketSegmentMigration())
    app.migrations.add(CreatePerfumeAccordsMigration())

    try app.autoMigrate().wait()

    try routes(app)
}

private enum DatabaseConfigurationError: LocalizedError {
    case missingDatabaseURL

    var errorDescription: String? {
        "DATABASE_URL is not configured. Add it to .env or export it before running Vapor."
    }
}
