// swift-tools-version:5.8

//
// This source file is part of the CardinalKit open-source project
// 
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
// 
// SPDX-License-Identifier: MIT
//

import PackageDescription


let package = Package(
    name: "CardinalKitViews",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "CardinalKitViews", targets: ["CardinalKitViews"])
    ],
    targets: [
        .target(
            name: "CardinalKitViews"
        ),
        .testTarget(
            name: "CardinalKitViewsTests",
            dependencies: [
                .target(name: "CardinalKitViews")
            ]
        )
    ]
)
