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


@Suite
@MainActor
struct PadSnapshotTests {
    @Test
    func reverseLabelStyle() {
        let label = SwiftUI.Label("100 %", image: "battery.100")
            .labelStyle(.reverse)

#if os(iOS)
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
#endif
    }

    @Test
    func listRow() {
        let row = List {
            ListRow("San Francisco") {
                Text(verbatim: "20 °C, Sunny")
            }
        }

        let largeRow = row
            .dynamicTypeSize(.accessibility3)

#if os(iOS)
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")

        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-XA3")
#endif
    }

    @Test
    func markdownView() async {
#if os(iOS)
        let markdownView = MarkdownView(
            markdown: Data("*Clean* Coding".utf8)
        )
            .multilineTextAlignment(.center)

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
    
    @Test
    func markdownView2() async throws {
        #if os(iOS)
        let view = MarkdownView(markdownDocument: try .init(processing: "*Clean* Coding"))
        assertSnapshot(
            of: view.multilineTextAlignment(.leading),
            as: .image(layout: .device(config: .iPhone13Pro)),
            named: "leading-iphone-regular"
        )
        assertSnapshot(
            of: view.multilineTextAlignment(.center),
            as: .image(layout: .device(config: .iPhone13Pro)),
            named: "center-iphone-regular"
        )
        assertSnapshot(
            of: view.multilineTextAlignment(.trailing),
            as: .image(layout: .device(config: .iPhone13Pro)),
            named: "trailing-iphone-regular"
        )
        #endif
    }
}
