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
    @Test("Tile Header Layout")
    func tileHeaderLayout() {
        struct TestView: View {
            private let alignment: HorizontalAlignment

            var body: some View {
                TileHeader(alignment: alignment) {
                    Image(systemName: "book.pages.fill")
                        .foregroundStyle(.teal)
                        .font(.custom("Task Icon", size: 30, relativeTo: .headline))
                        .dynamicTypeSize(...DynamicTypeSize.accessibility2)
                        .accessibilityHidden(true)
                } title: {
                    Text("Clean Code")
                } subheadline: {
                    Text("by Robert C. Martin")
                }
            }

            init(alignment: HorizontalAlignment) {
                self.alignment = alignment
            }
        }

        let leadingTileHeader = TestView(alignment: .leading)
        let centerTileHeader = TestView(alignment: .center)
        let trailingTileHeader = TestView(alignment: .trailing)

#if os(iOS)
        assertSnapshot(of: leadingTileHeader, as: .image(layout: .device(config: .iPhone13Pro)), named: "leading")
        assertSnapshot(of: centerTileHeader, as: .image(layout: .device(config: .iPhone13Pro)), named: "center")
        assertSnapshot(of: trailingTileHeader, as: .image(layout: .device(config: .iPhone13Pro)), named: "trailing")
#endif
    }

    @Test("Simple Tile")
    func simpleTile() {
        struct TileView: View {
            private let alignment: HorizontalAlignment

            var body: some View {
                SimpleTile(alignment: alignment) {
                    Text("Clean Code")
                } body: {
                    Text("A book by Robert C. Martin")
                } footer: {
                    Button {
                    } label: {
                        Text("Buy")
                            .frame(maxWidth: .infinity, minHeight: 30)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }

            init(alignment: HorizontalAlignment) {
                self.alignment = alignment
            }
        }

        let tileLeading = TileView(alignment: .leading)
        let tileCenter = TileView(alignment: .center)
        let tileTraining = TileView(alignment: .trailing)

#if os(iOS)
        assertSnapshot(of: tileLeading, as: .image(layout: .device(config: .iPhone13Pro)), named: "leading")
        assertSnapshot(of: tileCenter, as: .image(layout: .device(config: .iPhone13Pro)), named: "center")
        assertSnapshot(of: tileTraining, as: .image(layout: .device(config: .iPhone13Pro)), named: "trailing")
#endif
    }

    @Test("Completed Tile Header")
    func completedTileHeader() {
        let view = CompletedTileHeader {
            Text("Some Title")
        }

#if os(iOS)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "header")
#endif
    }
}
