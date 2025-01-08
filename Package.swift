// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "MGTooltips",
    platforms: [
        .iOS(.v13) // Supports iOS 13 and above
    ],
    products: [
        .library(
            name: "MGTooltips",
            targets: ["MGTooltips"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MGTooltips",
            dependencies: [],
            path: "MGTooltips/Sources",
            exclude: [TooltipsDemo],
            resources: [
                .process("Resources/Localizable.xcstrings") 
            ]
        ),
    ]
)
