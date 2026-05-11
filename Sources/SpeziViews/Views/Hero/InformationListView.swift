//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// Present informational content in a row-based style.
///
/// The `InformationListView` allows developers to present a unified style to display informational content as defined
/// by the ``InformationListView/Item`` type.
///
/// The following example displays an ``InformationListView`` with two information items:
/// ```swift
/// InformationListView {
///     InformationListView.Item(
///         iconSymbol: "pc",
///         title: "PC",
///         description: "This is a PC."
///     )
///     InformationListView.Item(
///         iconSymbol: "desktopcomputer",
///         title: "Mac",
///         description: "This is an iMac."
///     )
/// }
/// ```
public struct InformationListView: View {
    private let items: [Item]

    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(0..<items.count, id: \.self) { index in
                itemView(item: items[index])
            }
        }
    }

    /// Creates an `InformationListView` instance with a collection of items defined by the ``Item`` type.
    /// - Parameter items: The items that should be displayed.
    public init(items: [Item]) {
        self.items = items
    }

    /// Creates an `InformationListView` instance with a collection of items defined by the ``Item`` type.
    /// - Parameter items: The items that should be displayed.
    public init(@ArrayBuilder<Item> items: () -> [Item]) {
        self.init(items: items())
    }

    private func itemView(item: Item) -> some View {
        HStack(spacing: 10) {
            item.icon
                .font(.system(size: 40))
                .frame(width: 40)
                .foregroundColor(.accentColor)
                .padding()
                .accessibilityHidden(true)

            VStack(alignment: .leading) {
                item.title
                    .bold()
                    .accessibilityAddTraits(.isHeader)
                item.description
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
    }
}


#if DEBUG
#Preview {
    InformationListView {
        InformationListView.Item(
            iconSymbol: "pc",
            title: String("PC"),
            description: String("This is a PC.")
        )
        InformationListView.Item(
            iconSymbol: "desktopcomputer",
            title: String("Mac"),
            description: String("This is an iMac.")
        )
    }
}
#endif
