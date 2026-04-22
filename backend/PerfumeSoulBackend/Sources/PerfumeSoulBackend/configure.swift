import Vapor

public func configure(_ app: Application) throws {
    // Uncomment this if you want to serve files from /Public.
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    try routes(app)
}
