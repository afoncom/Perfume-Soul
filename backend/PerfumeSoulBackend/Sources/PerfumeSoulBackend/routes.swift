import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }

    app.get("hello") { _ async -> String in
        "Hello, world!"
    }

    app.get("perfumery-history", ":dateKey") { req async throws -> PerfumeryHistoryDay in
        guard let dateKey = req.parameters.get("dateKey") else {
            throw Abort(.badRequest)
        }

        let historyDay = try PerfumeryHistoryLoader.load()

        guard historyDay.dateKey == dateKey else {
            throw Abort(.notFound)
        }

        return historyDay
    }
}
