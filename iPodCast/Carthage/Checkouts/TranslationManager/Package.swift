// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "LocalizationManager",
    platforms: [.iOS(.v10), .macOS(.v10_12), .tvOS(.v10), .watchOS(.v3)],
    products: [
        .library(name: "LocalizationManager", targets: ["LocalizationManager"])
    ],
    targets: [
        .target(
            name: "LocalizationManager",
            path: "LocalizationManager/Classes"
        )
    ]
)
