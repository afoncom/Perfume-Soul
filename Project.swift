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
            deploymentTargets: .iOS("18.6"),
            infoPlist: .file(path: "PerfumeSoul/Info.plist"),
            sources: .sourceFilesList(globs: ["PerfumeSoul/**/*.swift"]),
            resources: [
                "PerfumeSoul/Assets.xcassets",
                "PerfumeSoul/Base.lproj/**"
            ],
            dependencies: []
        ),
        Target.target(
            name: "PerfumeSoulTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "afon-com.PerfumeSoulTests",
            deploymentTargets: .iOS("18.6"),
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
            deploymentTargets: .iOS("18.6"),
            infoPlist: .default,
            sources: .sourceFilesList(globs: ["PerfumeSoulUITests/**/*.swift"]),
            resources: [],
            dependencies: [
                .target(name: "PerfumeSoul")
            ]
        )
    ]
)
