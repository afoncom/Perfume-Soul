import Logging
import NIOCore
import NIOPosix
import Vapor

@main
enum Entrypoint {
    static func main() async throws {
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)

        let app = try await Application.make(env)

        do {
            let commandName = CommandLine.arguments.dropFirst().first
            try configure(
                app,
                needsDatabase: commandName != "catalog-audit"
            )
            if commandName == "serve" {
                _ = try await app.perfumeProfileCache.profiles(on: app.db)
            }
            try await app.execute()
        } catch {
            app.logger.report(error: error)
            try? await app.asyncShutdown()
            throw error
        }

        try await app.asyncShutdown()
    }
}
