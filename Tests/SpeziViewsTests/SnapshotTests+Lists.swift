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
    @Test("List Row")
    func listRow() {
        let row = List {
            ListRow("San Francisco") {
                Text(verbatim: "20 °C, Sunny")
            }
        }

        let largeRow = row
            .dynamicTypeSize(.accessibility3)

#if os(iOS)
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")

        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-XA3")
#endif
    }

    @Test("List Row Inits")
    func listRowInits() {
        let string = "Hello"

        _ = ListRow(string) {
            Text("World")
        }
        _ = ListRow(string, value: "World")
        _ = ListRow(string, value: Date.now, format: .dateTime)

        _ = ListRow("Hello") {
            Text("World")
        }
        _ = ListRow("Hello", value: "World")
        _ = ListRow("Hello", value: Date.now, format: .dateTime)

        _ = ListRow(verbatim: "Hello") {
            Text("World")
        }
    }

    @Test("List Header")
    func listHeader() {
        let listHeader0 = ListHeader(systemImage: "person.fill.badge.plus") {
            Text("Create a new Account", bundle: .module)
        } instructions: {
            Text("Please fill out the details below to create your new account.", bundle: .module)
        }

        let listHeader1 = ListHeader(systemImage: "person.fill.badge.plus") {
            Text("Create a new Account", bundle: .module)
        }

#if os(iOS)
        assertSnapshot(of: listHeader0, as: .image(layout: .device(config: .iPhone13Pro)), named: "list-header-instructions")
        assertSnapshot(of: listHeader1, as: .image(layout: .device(config: .iPhone13Pro)), named: "list-header")
#endif
    }
}
