import Foundation
import Vapor

struct CatalogAuditCommand: Command {
    struct Signature: CommandSignature {
        @Argument(name: "input")
        var inputPath: String

        @Option(name: "target-count", short: "t", help: "Maximum number of curated perfumes")
        var targetCount: Int?

        @Option(name: "brand-cap", short: "b", help: "Maximum curated perfumes per brand")
        var brandCap: Int?

        init() { }
    }

    let help = "Audits a semicolon-delimited Fragrantica CSV without modifying the database."

    func run(using context: CommandContext, signature: Signature) throws {
        let url = URL(fileURLWithPath: signature.inputPath)
        let contents = try String(contentsOf: url, encoding: .isoLatin1)
        let sourcePerfumes = try CatalogSourcePerfumeParser.parse(contents)
        let report = CatalogImportAudit.makeReport(
            sourcePerfumes: sourcePerfumes,
            policy: CatalogSelectionPolicy(
                targetCount: signature.targetCount ?? 15_000,
                maximumPerBrand: signature.brandCap ?? 200
            )
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        context.console.print(String(decoding: try encoder.encode(report), as: UTF8.self))
    }
}
