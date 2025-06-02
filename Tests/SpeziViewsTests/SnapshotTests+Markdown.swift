//
//  SnapshotTests+Texts.swift
//  SpeziViews
//
//  Created by Max Rosenblattl on 12.05.25.
//

//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SnapshotTesting
@testable import SpeziViews
import SwiftUI
import XCTest

@MainActor
final class MarkdownViewSnapshotTests: XCTestCase {
    func testReverseLabelStyle() {
        let label = SwiftUI.Label("100 %", image: "battery.100")
            .labelStyle(.reverse)

#if os(iOS)
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
#endif
    }

    func testMarkdownView() async {
#if os(iOS)
        let markdownView = MarkdownView(markdown: Data("*Clean* Coding".utf8))

        let host = UIHostingController(rootView: markdownView)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.layoutIfNeeded()
        await Task.yield()
        host.view.layoutIfNeeded()

        assertSnapshot(
            of: window,
            as: .image,
            named: "iphone-regular"
        )
#endif
    }
}
