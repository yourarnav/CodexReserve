// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodexBar",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CodexBar",
            path: "Sources/CodexBar"
        )
    ]
)
