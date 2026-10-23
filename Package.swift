// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CapsuleSegmentKit",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "CapsuleSegmentKit",
            targets: ["CapsuleSegmentKit"]
        ),
    ],
    targets: [
        .target(
            name: "CapsuleSegmentKit"
        ),
        // 範例 App：在 Xcode 選擇 CapsuleSegmentDemo scheme + My Mac 執行
        .executableTarget(
            name: "CapsuleSegmentDemo",
            dependencies: ["CapsuleSegmentKit"],
            path: "Examples/CapsuleSegmentDemo"
        ),
        .testTarget(
            name: "CapsuleSegmentKitTests",
            dependencies: ["CapsuleSegmentKit"]
        ),
    ]
)
