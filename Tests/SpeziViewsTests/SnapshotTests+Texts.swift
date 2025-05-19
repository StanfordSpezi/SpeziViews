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
import Testing

extension SnapshotTests {
    @Test("Reverse Label Style")
    func reverseLabelStyle() {
        let label = SwiftUI.Label("100 %", image: "battery.100")
            .labelStyle(.reverse)

#if os(iOS)
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
//        assertSnapshot(of: label, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
#endif
    }

    @Test("Lazy Text")
    func lazyText() {
        let longString = String(repeating: "Clean Code\nA Handbook of Agile Software Craftsmanship\nby Robert C. Martin\n", count: 100)
        let lazyText = LazyText(verbatim: longString)

#if os(iOS)
        assertSnapshot(of: lazyText, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
    }

    @Test("Labeled Content")
    func labeledContent() {
        let labeledContent = LabeledContent("Clean") {
            Text(verbatim: "Code")
        }

#if os(iOS)
        assertSnapshot(of: labeledContent, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
    }

#if os(iOS)
    @Test("Markdown View")
    func markdownView() async {
        let markdownView = MarkdownView(markdown: Data("*Clean* Coding".utf8))

        let host = UIHostingController(rootView: markdownView)
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = host
        window.makeKeyAndVisible()

        host.view.layoutIfNeeded()
        await Task.yield()

        assertSnapshot(of: window, as: .image, named: "iphone-regular")
    }
#endif
}
