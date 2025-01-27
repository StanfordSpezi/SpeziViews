// swift-tools-version:6.0

//
// This source file is part of the Stanford Spezi open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import class Foundation.ProcessInfo
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
        .package(url: "https://github.com/StanfordSpezi/Spezi.git", from: "1.8.0"),
        .package(url: "https://github.com/StanfordSpezi/SpeziFoundation.git", from: "2.0.1"),
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.0"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.17.0")
    ] + swiftLintPackage(),
    targets: [
        .target(
            name: "SpeziViews",
            dependencies: [
                .product(name: "Spezi", package: "Spezi")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziPersonalInfo",
            dependencies: [
                .target(name: "SpeziViews")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .target(
            name: "SpeziValidation",
            dependencies: [
                .target(name: "SpeziViews"),
                .product(name: "OrderedCollections", package: "swift-collections")
            ],
            plugins: [] + swiftLintPlugin()
        ),
        .testTarget(
            name: "SpeziViewsTests",
            dependencies: [
                .target(name: "SpeziViews"),
                .target(name: "SpeziValidation"),
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            plugins: [] + swiftLintPlugin()
        )
    ]
)


func swiftLintPlugin() -> [Target.PluginUsage] {
    // Fully quit Xcode and open again with `open --env SPEZI_DEVELOPMENT_SWIFTLINT /Applications/Xcode.app`
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLint")]
    } else {
        []
    }
}

func swiftLintPackage() -> [PackageDescription.Package.Dependency] {
    if ProcessInfo.processInfo.environment["SPEZI_DEVELOPMENT_SWIFTLINT"] != nil {
        [.package(url: "https://github.com/realm/SwiftLint.git", from: "0.55.1")]
    } else {
        []
    }
}
