// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Portway",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "Portway",
            path: "Sources/Portway",
            exclude: ["Resources/Info.plist"]
        )
    ]
)
