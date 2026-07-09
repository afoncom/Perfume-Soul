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
        .package(url: "https://github.com/vapor/fluent-kit.git", from: "1.52.2"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.9.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
    ],
    targets: [
        .target(
            name: "CAstronomy",
            path: "Sources/CAstronomy",
            publicHeadersPath: "include"
        ),
        .executableTarget(
            name: "PerfumeSoulBackend",
            dependencies: [
                .target(name: "CAstronomy"),
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQL", package: "fluent-kit"),
                .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
            ],
            resources: [
                .process("Requests/quiz-of-the-day/Resources")
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
