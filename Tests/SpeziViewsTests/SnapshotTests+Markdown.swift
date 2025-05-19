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
    }
}
#endif
