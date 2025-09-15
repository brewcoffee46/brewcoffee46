// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BrewCoffee46Core",
    platforms: [.iOS(.v17), .watchOS(.v10)],
    products: [
        .library(name: "BrewCoffee46Core", targets: ["BrewCoffee46Core"]),
        .library(name: "BrewCoffee46TestsShared", targets: ["BrewCoffee46TestsShared"]),
    ],
    dependencies: [
        .package(url: "https://github.com/hmlongco/Factory.git", from: "2.5.3")
    ],
    targets: [
        .target(
            name: "BrewCoffee46TestsShared",
            dependencies: [
                "BrewCoffee46Core"
            ]
        ),
        .target(
            name: "BrewCoffee46Core",
            dependencies: [
                "Factory"
            ]
        ),
        .testTarget(
            name: "BrewCoffee46CoreTests",
            dependencies: [
                "BrewCoffee46Core",
                "BrewCoffee46TestsShared",
            ]
        ),
    ]
)
