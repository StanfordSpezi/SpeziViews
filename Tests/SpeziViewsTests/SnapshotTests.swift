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
    @MainActor
    func testListRow() {
        let row = List {
            ListRow("San Francisco") {
                Text(verbatim: "20 °C, Sunny")
            }
        }
        
        let largeRow = row
            .dynamicTypeSize(.accessibility3)

#if os(iOS)
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: row, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")

        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-XA3")
        assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-XA3")
#endif
    }

    @MainActor
    func testReverseLabelStyle() {
        let label = SwiftUI.Label("100 %", image: "battery.100")
            .labelStyle(.reverse)

#if os(iOS)
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: label, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
#endif
    }

    @MainActor
    func testDismissButton() {
        let dismissButton = DismissButton()


#if os(iOS)
        assertSnapshot(of: dismissButton, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
        assertSnapshot(of: dismissButton, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
#endif
    }

    @MainActor
    func testImageReference() throws {
        let eraser: ImageReference = .system("eraser.fill")
        let nonExistingImage: ImageReference = .asset("does not exist", bundle: .main)

        XCTAssertTrue(eraser.isSystemImage)
        XCTAssertFalse(nonExistingImage.isSystemImage)

        let image = try XCTUnwrap(eraser.image)
        XCTAssertNil(nonExistingImage.image)

#if canImport(WatchKit)
        XCTAssertNotNil(eraser.wkImage)
        XCTAssertNil(nonExistingImage.wkImage)
#endif

#if canImport(UIKit)
        XCTAssertNotNil(eraser.uiImage)
        XCTAssertNil(nonExistingImage.uiImage)
#elseif canImport(AppKit)
        XCTAssertNotNil(eraser.nsImage)
        XCTAssertNil(nonExistingImage.nsImage)
#endif

#if os(iOS)
        assertSnapshot(of: image, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
    }

    @MainActor
    func testTileHeaderLayout() {
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

    @MainActor
    func testSimpleTile() {
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

    @MainActor
    func testCompletedTileHeader() {
        let view = CompletedTileHeader {
            Text("Some Title")
        }

#if os(iOS)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "header")
#endif
    }

    @MainActor
    func testListRowInits() {
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

    @MainActor
    func testListHeader() {
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
    
    @MainActor
    func testSkeletonLoading() {
        let view =
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .frame(height: 100)
                .skeletonLoading(replicationCount: 5, repeatInterval: 1.5, spacing: 16)
                .padding()
            Spacer()
        }

#if os(iOS)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "skeleton-loading")
#endif
    }
}
