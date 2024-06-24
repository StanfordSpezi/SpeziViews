// swift-tools-version:5.9

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "SpeziViews",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .visionOS(.v1),
        .tvOS(.v17),
        .watchOS(.v10),
        .macOS(.v14)
    ],
    products: [
        .library(name: "SpeziViews", targets: ["SpeziViews"]),
        .library(name: "SpeziPersonalInfo", targets: ["SpeziPersonalInfo"]),
        .library(name: "SpeziValidation", targets: ["SpeziValidation"])
    ],
    dependencies: [
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.15.3"),
        .package(url: "https://github.com/realm/SwiftLint.git", .upToNextMinor(from: "0.55.1"))
    ],
    targets: [
        .target(
            name: "SpeziViews",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ],
            plugins: [.swiftLintPlugin]
        ),
        .target(
            name: "SpeziPersonalInfo",
            dependencies: [
                .target(name: "SpeziViews")
            ],
            plugins: [.swiftLintPlugin]
        ),
        .target(
            name: "SpeziValidation",
            dependencies: [
                .target(name: "SpeziViews"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            plugins: [.swiftLintPlugin]
        ),
        .testTarget(
            name: "SpeziViewsTests",
            dependencies: [
                .target(name: "SpeziViews"),
                .target(name: "SpeziValidation"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            plugins: [.swiftLintPlugin]
        )
    ]
)


extension Target.PluginUsage {
    static var swiftLintPlugin: Target.PluginUsage {
        .plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")
    }
}
