// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "KeyLock",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "KeyLock",
            path: "Sources/KeyLock"
        )
    ]
)
