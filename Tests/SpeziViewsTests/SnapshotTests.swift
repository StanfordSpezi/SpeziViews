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


@Suite("Snapshot Tests")
struct SnapshotTests {
    // MARK: - Lists
    @MainActor
    struct Lists {
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
            assertSnapshot(of: row, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")

            assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-XA3")
            assertSnapshot(of: largeRow, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-XA3")
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

    // MARK: - Texts
    @MainActor
    struct Texts {
        @Test("Reverse Label Style")
        func reverseLabelStyle() {
            let label = SwiftUI.Label("100 %", image: "battery.100")
                .labelStyle(.reverse)

#if os(iOS)
            assertSnapshot(of: label, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
            assertSnapshot(of: label, as: .image(layout: .device(config: .iPadPro11)), named: "ipad-regular")
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

        @Test("Markdown View")
        func markdownView() async throws {
            let markdownView = MarkdownView(markdown: Data("*Clean* Coding".utf8))

            try? await Task.sleep(nanoseconds: 1_000)


#if os(iOS)
            assertSnapshot(of: markdownView, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
        }
    }

    // MARK: - Buttons
    struct Buttons {
        @MainActor
        struct TestView: View {
            enum ButtonType: String {
                case dismiss, info, async
            }
            let type: ButtonType

            var body: some View {
                switch type {
                case .dismiss:
                    DismissButton()
                case .info:
                    InfoButton("Clean Code", action: {})
                case .async:
                    AsyncButton("Clean Code") {
                        try? await Task.sleep(nanoseconds: 1_000)
                    }
                }
            }

            init(type: ButtonType) {
                self.type = type
            }
        }


        @MainActor
        @Test("Buttons", arguments: [
            await TestView(type: .dismiss),
            await TestView(type: .info),
            await TestView(type: .async)
        ])
        func allButtons(_ button: TestView) async throws {
#if os(iOS)
            assertSnapshot(of: button, as: .image(layout: .device(config: .iPhone13Pro)), named: "button-" + button.type.rawValue)
#endif
        }
    }


    // MARK: - Controls
    @MainActor
    struct Controls {
        struct Options: OptionSet, PickerValue {
            var localizedStringResource: LocalizedStringResource {
                "Option \(rawValue)"
            }
            var rawValue: UInt8
            static let allCases: [Options] = [.option1, .option2]

            static let option1 = Options(rawValue: 1 << 0)
            static let option2 = Options(rawValue: 1 << 1)
        }

        enum Version: PickerValue {
            case versionA
            case versionB

            var localizedStringResource: LocalizedStringResource {
                switch self {
                case .versionA:
                    "A"
                case .versionB:
                    "B"
                }
            }
        }

        @Test("Option Set Picker")
        func optionSetPicker() {
            let picker0 = List {
                OptionSetPicker("Clean", selection: .constant(Options.option1))
            }
            let picker1 = List {
                OptionSetPicker("Code", selection: .constant(Options.option1.union(.option2)), style: .inline, allowEmptySelection: true)
            }

#if os(iOS)
            assertSnapshot(of: picker0, as: .image(layout: .device(config: .iPhone13Pro)), named: "option-picker")
            assertSnapshot(of: picker1, as: .image(layout: .device(config: .iPhone13Pro)), named: "option-picker-inline")
#endif
        }

        @Test("Case Iterable Picker")
        func caseIterablePicker() {
            let picker = List {
                CaseIterablePicker("Clean Code", selection: .constant(Version.versionA))
            }

#if os(iOS)
            assertSnapshot(of: picker, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
        }
    }


    // MARK: - Tiles
    @MainActor
    struct Tiles {
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

    // MARK: - Layout
    @MainActor
    struct Layout {
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
    }


    // MARK: - Miscellaneous
    @MainActor
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

    @MainActor
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
