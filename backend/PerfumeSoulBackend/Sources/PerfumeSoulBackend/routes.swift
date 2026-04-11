import Vapor

func routes(_ app: Application) throws {
    app.get { _ async in
        "It works!"
    }

    app.get("hello") { _ async -> String in
        "Hello, world!"
    }

    app.get("horoscope", "daily", ":sign", ":date") { req async throws -> DailyHoroscope in
        guard
            let sign = req.parameters.get("sign"),
            let date = req.parameters.get("date")
        else {
            throw Abort(.badRequest)
        }

        let horoscope = try DailyHoroscopeLoader.load()

        guard horoscope.sign == sign, horoscope.date == date else {
            throw Abort(.notFound)
        }

        return horoscope
    }
}
