// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "ZiweiCore",
    platforms: [.iOS(.v17), .macOS(.v13)],
    products: [
        .library(name: "ZiweiCore", targets: ["ZiweiCore"]),
    ],
    targets: [
        .target(name: "ZiweiCore"),
        .executableTarget(
            name: "ZiweiCoreTests",
            dependencies: ["ZiweiCore"],
            path: "Tests/ZiweiCoreTests"
        ),
    ]
)
