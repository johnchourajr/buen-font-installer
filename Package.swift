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
    dependencies: [
        .package(url: "https://github.com/sparkle-project/Sparkle", from: "2.6.0")
    ],
    targets: [
        .executableTarget(
            name: "BuenFontInstaller",
            dependencies: [
                .product(name: "Sparkle", package: "Sparkle")
            ],
            path: "Sources",
            resources: [
                .process("Resources")
            ])
    ]
)
