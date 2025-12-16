// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "Tools",
    dependencies: [
        .package(url: "https://github.com/apple/swift-format.git", from: "602.0.0"),
        .package(url: "https://github.com/yonaskolb/XcodeGen.git", from: "2.44.1"),
        .package(url: "https://github.com/mono0926/LicensePlist.git", from: "3.27.2"),
    ]
)
