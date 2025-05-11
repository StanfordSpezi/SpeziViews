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


@MainActor
@Suite("Snapshot Tests")
struct SnapshotTests {
    @Test("Description Grid Row")
    func descriptionGridRow() {
        let view = VStack {
            Form {
                Grid(horizontalSpacing: 8, verticalSpacing: 8) {
                    DescriptionGridRow {
                        Text(verbatim: "Description")
                    } content: {
                        Text(verbatim: "Content")
                    }
                    Divider()
                    DescriptionGridRow {
                        Text(verbatim: "Description")
                    } content: {
                        Text(verbatim: "Content")
                    }
                    DescriptionGridRow {
                        Text(verbatim: "Description")
                    } content: {
                        Text(verbatim: "Content")
                    }
                }
            }
        }
#if os(iOS)
            assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "header")
#endif
    }

    @Test("Dynamic HStack")
    func dynamicHStack() {
        let view = List {
            DynamicHStack(verticalAlignment: .center) {
                Text(verbatim: "Hello World:")
                Text(verbatim: "How are you doing?")
                    .foregroundColor(.secondary)
            }
        }

#if os(iOS)
        assertSnapshot(of: view, as: .image(layout: .device(config: .iPhone13Pro)), named: "header")
#endif
    }


    @Test("Image Reference")
    func imageReference() throws {
        let eraser: ImageReference = .system("eraser.fill")
        let nonExistingImage: ImageReference = .asset("does not exist", bundle: .main)

        #expect(eraser.isSystemImage)
        #expect(nonExistingImage.isSystemImage == false)

        let image = try #require(eraser.image)
        #expect(nonExistingImage.image == nil)

#if canImport(WatchKit)
        #expect(eraser.wkImage != nil)
        #expect(nonExistingImage.wkImage == nil)
#endif

#if canImport(UIKit)
        #expect(eraser.uiImage != nil)
        #expect(nonExistingImage.uiImage == nil)
#elseif canImport(AppKit)
        #expect(eraser.nsImage != nil)
        #expect(nonExistingImage.nsImage == nil)
#endif

#if os(iOS)
        assertSnapshot(of: image, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
    }

    @Test("Skeleton Loading")
    func skeletonLoading() {
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
