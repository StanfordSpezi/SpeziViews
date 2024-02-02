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


final class SnapshotTests: XCTestCase {
    func testListRow() {
        let row = List {
            ListRow(verbatim: "San Francisco") {
                Text(verbatim: "20 °C, Sunny")
            }
        }

        let largeRow = row
            .dynamicTypeSize(.accessibility3)

        // TODO: fixed size of visionOS?
#if os(iOS)
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")

        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-XA3")
        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-XA3")
#elseif os(visionOS)

#endif
    }
}
