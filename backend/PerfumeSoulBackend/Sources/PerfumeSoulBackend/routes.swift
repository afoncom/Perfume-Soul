import Foundation
import Vapor

func routes(_ app: Application) throws {
    app.get("perfumery-history", ":dateKey") { req async throws -> Response in
        guard let dateKey = req.parameters.get("dateKey") else {
            throw Abort(.badRequest)
        }

        let items: [PerfumeryHistoryItem]

        do {
            items = try PerfumeryHistoryLoader.load(dateKey: dateKey)
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            throw Abort(.notFound)
        } catch let error as CocoaError where error.code == .fileReadCorruptFile {
            throw Abort(.badRequest)
        }

        return try jsonResponse(items)
    }

    app.get("horoscope", "daily") { _ async throws -> Response in
        do {
            return try jsonResponse(DailyHoroscopeLoader.loadForToday())
        } catch let error as CocoaError where error.code == .fileNoSuchFile {
            throw Abort(.notFound)
        } catch {
            throw error
        }
    }
}

private func jsonResponse<T: Encodable>(_ value: T) throws -> Response {
    let data = try JSONEncoder().encode(value)

    var headers = HTTPHeaders()
    headers.contentType = .json

    return Response(status: .ok, headers: headers, body: .init(data: data))
}
