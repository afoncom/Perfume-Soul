import Foundation
import Testing
@testable import PerfumeSoulBackend

struct FragellaImageTests {
    @Test("Selects only an exact fragrance from the same brand")
    func exactMatch() throws {
        let response = """
        [
            {"Name":"Sauvage Elixir","Brand":"Dior","Image URL":"https://cdn.fragella.com/images/elixir.jpg"},
            {"Name":"Dior Sauvage","Brand":"Dior","Image URL":"https://cdn.fragella.com/images/sauvage.jpg"},
            {"Name":"Sauvage","Brand":"Other","Image URL":"https://cdn.fragella.com/images/other.jpg"}
        ]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage")
            == "https://cdn.fragella.com/images/sauvage.jpg")
        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage Parfum") == nil)
    }

    @Test("Rejects image URLs outside Fragella CDN")
    func rejectsRetailerImage() throws {
        let response = """
        [{"Name":"Sauvage","Brand":"Dior","Image URL":"https://shop.example.com/sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(in: matches, brand: "Dior", name: "Sauvage") == nil)
    }

    @Test("Rejects a different concentration")
    func rejectsDifferentConcentration() throws {
        let response = """
        [{"Name":"Sauvage","Brand":"Dior","OilType":"Eau de Toilette","Image URL":"https://cdn.fragella.com/images/sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(
            in: matches, brand: "Dior", name: "Sauvage", concentration: "Eau de Parfum"
        ) == nil)
    }

    @Test("Matches Dior with Fragella's Christian Dior brand name")
    func matchesDiorAlias() throws {
        let response = """
        [{"Name":"Dior Sauvage","Brand":"Christian Dior","OilType":"Eau de Toilette","Image URL":"https://cdn.fragella.com/images/dior-sauvage.jpg"}]
        """
        let matches = try JSONDecoder().decode([FragellaFragrance].self, from: Data(response.utf8))

        #expect(FragellaImageLookup.imageURL(
            in: matches, brand: "Dior", name: "Sauvage", concentration: "eau de toilette"
        ) == "https://cdn.fragella.com/images/dior-sauvage.jpg")
    }
}
