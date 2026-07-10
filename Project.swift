import ProjectDescription

let project = Project(
    name: "PerfumeSoul",
    organizationName: "afon.com",
    targets: [
        Target.target(
            name: "PerfumeSoul",
            destinations: .iOS,
            product: .app,
            bundleId: "afon-com.PerfumeSoul",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .file(path: "PerfumeSoul/Info.plist"),
            sources: .sourceFilesList(globs: ["PerfumeSoul/**/*.swift", "PerfumeSoul/**/*.c"]),
            resources: [
                "PerfumeSoul/Resources/Assets.xcassets",
                "PerfumeSoul/Resources/Base.lproj/**",
                "PerfumeSoul/Classes/Core/CoreData/**/*.xcdatamodeld",
                "PerfumeSoul/Resources/en.lproj/**",
                "PerfumeSoul/Resources/ru.lproj/**"
            ],
            dependencies: [],
            settings: .settings(
                base: [
                    "ASSETCATALOG_COMPILER_GENERATE_ASSET_SYMBOLS": "YES",
                    "ASSETCATALOG_COMPILER_GENERATE_SWIFT_ASSET_SYMBOL_EXTENSIONS": "YES",
                    "SWIFT_OBJC_BRIDGING_HEADER": "PerfumeSoul/Classes/Services/ProfileCalculation/Astronomy/PerfumeSoul-Bridging-Header.h",
                    "HEADER_SEARCH_PATHS": "$(inherited) $(SRCROOT)/PerfumeSoul/Classes/Services/ProfileCalculation/Astronomy/CAstronomy/include"
                ]
            )
        ),
        Target.target(
            name: "PerfumeSoulTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "afon-com.PerfumeSoulTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: .sourceFilesList(globs: ["PerfumeSoulTests/**/*.swift"]),
            resources: [],
            dependencies: [
                .target(name: "PerfumeSoul")
            ]
        ),
        Target.target(
            name: "PerfumeSoulUITests",
            destinations: .iOS,
            product: .uiTests,
            bundleId: "afon-com.PerfumeSoulUITests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            sources: .sourceFilesList(globs: ["PerfumeSoulUITests/**/*.swift"]),
            resources: [],
            dependencies: [
                .target(name: "PerfumeSoul")
            ]
        )
    ]
)
