// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "CodexReserve",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "CodexReserve",
            path: "Sources/CodexReserve"
        )
    ]
)
