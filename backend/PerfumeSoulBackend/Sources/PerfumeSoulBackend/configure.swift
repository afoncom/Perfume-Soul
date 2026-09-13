import Fluent
import FluentPostgresDriver
import Vapor

public func configure(_ app: Application, needsDatabase: Bool = true) throws {
    // Uncomment this if you want to serve files from /Public.
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    app.commands.use(CatalogAuditCommand(), as: "catalog-audit")
    app.asyncCommands.use(CatalogImportCommand(), as: "catalog-import")

    guard needsDatabase else {
        return
    }

    guard let databaseURL = Environment.get("DATABASE_URL") else {
        throw DatabaseConfigurationError.missingDatabaseURL
    }

    app.databases.use(try .postgres(url: databaseURL), as: .psql)
    app.migrations.add(CreateBaseSchemaMigration())
    app.migrations.add(AddPerfumeScoreColumnsMigration())
    app.migrations.add(AddPerfumeProfileMetadataMigration())
    app.migrations.add(AddPerfumeMarketSegmentMigration())
    app.migrations.add(CreatePerfumeAccordsMigration())
    app.migrations.add(AddPerfumeStoryMetadataMigration())
    app.migrations.add(AddPerfumeStoryEnglishMetadataMigration())
    app.migrations.add(AddNoteEnglishNameMigration())
    app.migrations.add(AddCatalogImportSupportMigration())
    app.migrations.add(CreateUnfoundSearchQueriesMigration())

    try app.autoMigrate().wait()

    try routes(app)
}

private enum DatabaseConfigurationError: LocalizedError {
    case missingDatabaseURL

    var errorDescription: String? {
        "DATABASE_URL is not configured. Add it to .env or export it before running Vapor."
    }
}
