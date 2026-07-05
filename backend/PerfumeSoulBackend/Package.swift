// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "PerfumeSoulBackend",
    platforms: [
        .macOS(.v13),
        .iOS(.v18)
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.115.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.11.0"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    ],
    targets: [
        .executableTarget(
            name: "PerfumeSoulBackend",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            resources: [
                .process("Requests/quiz-of-the-day/Resources"),
                .process("Requests/perfume-recommendations/Resources")
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "PerfumeSoulBackendTests",
            dependencies: [
                .target(name: "PerfumeSoulBackend"),
                .product(name: "VaporTesting", package: "vapor"),
            ],
            swiftSettings: swiftSettings
        ),
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("ExistentialAny"),
] }
