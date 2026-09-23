import Foundation
import Vapor

struct CatalogImportCommand: AsyncCommand {
    struct Signature: CommandSignature {
        @Argument(name: "input")
        var inputPath: String

        @Option(name: "target-count", short: "t", help: "Total size of the curated catalogue")
        var targetCount: Int?

        @Option(name: "brand-cap", short: "b", help: "Maximum curated perfumes per brand")
        var brandCap: Int?

        @Option(name: "batch-size", short: "s", help: "Number of selected perfumes to import")
        var batchSize: Int?

        init() { }
    }

    let help = "Imports one curated catalogue batch from a semicolon-delimited CSV."

    func run(using context: CommandContext, signature: Signature) async throws {
        let sourceData = try Data(contentsOf: URL(fileURLWithPath: signature.inputPath))
        let source = try CatalogSourceFileDecoder.decode(sourceData)
        let targetCount = signature.targetCount ?? 15_000
        let batchSize = min(max(signature.batchSize ?? 500, 1), 1_000)
        let currentCatalogCount = try await PerfumeModel.query(on: context.application.db).count()
        guard currentCatalogCount < targetCount else {
            context.console.print("Catalogue already contains \(currentCatalogCount) perfumes; target is \(targetCount).")
            return
        }

        let brandCap = signature.brandCap ?? 200
        let selection = CuratedCatalogSelector.select(
            from: try CatalogSourcePerfumeParser.parse(source),
            policy: CatalogSelectionPolicy(
                targetCount: .max,
                maximumPerBrand: brandCap
            )
        )
        let existingIdentities = try await CatalogDatabaseImporter.existingPerfumeIdentities(
            on: context.application.db
        )
        var brandCounts = try await CatalogDatabaseImporter.existingBrandCounts(
            on: context.application.db
        )
        var candidates: [CatalogSourcePerfume] = []
        for sourcePerfume in selection.selected {
            let perfume = try CatalogPreparedPerfume(source: sourcePerfume)
            guard !existingIdentities.contains(perfume.identity) else {
                continue
            }

            let brandKey = normalized(perfume.brandName)
            guard brandCounts[brandKey, default: 0] < brandCap else {
                continue
            }

            candidates.append(sourcePerfume)
            brandCounts[brandKey, default: 0] += 1
        }
        let remainingCount = targetCount - currentCatalogCount
        let batch = Array(candidates.prefix(min(batchSize, remainingCount)))
        let result = try await CatalogDatabaseImporter.importBatch(batch, on: context.application.db)
        let catalogCountAfterImport = try await PerfumeModel.query(on: context.application.db).count()
        let unclassifiedReport = try await CatalogDatabaseImporter.unclassifiedReport(
            on: context.application.db
        )
        let output = CatalogImportCommandResult(
            targetCatalogCount: targetCount,
            catalogCountBeforeImport: currentCatalogCount,
            catalogCountAfterImport: catalogCountAfterImport,
            matchingCandidatesRemaining: candidates.count - batch.count,
            batch: result,
            unclassifiedReport: unclassifiedReport,
            segmentationNextStep: "All imported perfumes start as unclassified. Run scripts/classify_curated_catalog_segments.sql, then manually classify the remaining brands listed in unclassifiedReport."
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        context.console.print(String(decoding: try encoder.encode(output), as: UTF8.self))
    }
}

private struct CatalogImportCommandResult: Codable {
    let targetCatalogCount: Int
    let catalogCountBeforeImport: Int
    let catalogCountAfterImport: Int
    let matchingCandidatesRemaining: Int
    let batch: CatalogImportBatchResult
    let unclassifiedReport: CatalogUnclassifiedReport
    let segmentationNextStep: String
}
