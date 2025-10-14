// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "BuenFontInstaller",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "BuenFontInstaller",
            targets: ["BuenFontInstaller"])
    ],
    targets: [
        .executableTarget(
            name: "BuenFontInstaller",
            path: "Sources",
            resources: [
                .process("Resources")
            ])
    ]
)

