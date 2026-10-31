import XCTest
@testable import PerfumeSoul

@MainActor
final class SceneDelegateBackendURLTests: XCTestCase {
    func testDefaultLaunchKeepsRemoteBackend() {
        XCTAssertEqual(SceneDelegate.backendBaseURL(environment: [:]), "http://82.97.248.219")
    }

    func testExplicitLaunchOverrideSelectsLocalBackend() {
        XCTAssertEqual(
            SceneDelegate.backendBaseURL(environment: ["PERFUME_SOUL_BACKEND_URL": "http://127.0.0.1:8080/"]),
            "http://127.0.0.1:8080"
        )
    }

    func testInvalidOverrideKeepsWorkingDefault() {
        for value in ["", "localhost:8080", "file:///tmp/backend"] {
            XCTAssertEqual(
                SceneDelegate.backendBaseURL(environment: ["PERFUME_SOUL_BACKEND_URL": value]),
                "http://82.97.248.219"
            )
        }
    }
}
