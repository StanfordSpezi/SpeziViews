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
}
