//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A header layout for tiles.
///
/// A header layout that consists of an icon, a title and an optional subheadline.
///
/// ```swift
/// TileHeader(alignment: .center) {
///     Image(systemName: "book.pages.fill")
///         .foregroundStyle(.teal)
///         .font(.custom("Task Icon", size: 30, relativeTo: .headline))
///         .dynamicTypeSize(...DynamicTypeSize.accessibility2)
/// } title: {
///     Text("Clean Code")
/// } subheadline: {
///     Text("by Robert C. Martin")
/// }
/// ```
///
/// The view automatically adapts it layout based on the  `HorizontalAlignment` and the available space.
///
/// @Row {
///     @Column {
///         @Image(source: "Tile-Leading", alt: "A `SimpleTile` view with a `TileHeader` view with `leading` alignment.") {
///             A `TileHeader` used with the ``SimpleTile`` view and `leading` alignment.
///         }
///     }
///     @Column {
///         @Image(source: "Tile-Center", alt: "A `SimpleTile` view with a `TileHeader` view with `center` alignment.") {
///             A `TileHeader` used with the ``SimpleTile`` view and `center` alignment.
///         }
///     }
///     @Column {
///         @Image(source: "Tile-Trailing", alt: "A `SimpleTile` view with a `TileHeader` view with `center` alignment.") {
///             A `TileHeader` used with the ``SimpleTile`` view and `trailing` alignment.
///         }
///     }
/// }
public struct TileHeader<Icon: View, Title: View, Subheadline: View>: View {
    private let alignment: HorizontalAlignment
    private let icon: Icon
    private let title: Title
    private let subheadline: Subheadline

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize

    public var body: some View {
        if alignment == .center {
            VStack(alignment: .center, spacing: 4) {
                icon
                modifiedTitle
                modifiedSubheadline
            }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        } else {
            ViewThatFits(in: .horizontal) {
                HStack {
                    icon // icon drawn before both title and subheadline

                    VStack(alignment: alignment, spacing: 4) {
                        modifiedTitle
                        modifiedSubheadline
                    }
                }

                VStack(alignment: alignment, spacing: 4) {
                    HStack(alignment: .center) {
                        if dynamicTypeSize < .accessibility3 {
                            icon // icon drawn just next to the title, subheadline below
                        }
                        modifiedTitle
                    }
                    modifiedSubheadline
                }
            }
            .accessibilityElement(children: .combine)
        }
    }

    private var modifiedTitle: some View {
        title
            .font(.headline)
    }

    private var modifiedSubheadline: some View {
        subheadline
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    /// Create a new tile header.
    /// - Parameters:
    ///   - alignment: The horizontal alignment of the header.
    ///   - icon: The primary
    ///   - title: The title view.
    ///   - subheadline: The subheadline.
    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title,
        @ViewBuilder subheadline: () -> Subheadline
    ) {
        self.alignment = alignment
        self.icon = icon()
        self.title = title()
        self.subheadline = subheadline()
    }

    
    /// Create a new tile header without a subheadline.
    /// - Parameters:
    ///   - alignment: The horizontal alignment of the header.
    ///   - icon: The primary
    ///   - title: The title view.
    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder icon: () -> Icon,
        @ViewBuilder title: () -> Title
    ) where Subheadline == EmptyView {
        self.alignment = alignment
        self.icon = icon()
        self.title = title()
        self.subheadline = EmptyView()
    }
}


#if DEBUG
#Preview {
    List {
        TileHeader {
            Image(systemName: "book.pages.fill")
                .foregroundStyle(.teal)
                .font(.custom("Task Icon", size: 30, relativeTo: .headline))
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        } title: {
            Text("Awesome Book")
        } subheadline: {
            Text("This a nice book recommendation")
        }
    }
}

#Preview {
    List {
        TileHeader(alignment: .center) {
            Image(systemName: "book.pages.fill")
                .foregroundStyle(.teal)
                .font(.custom("Task Icon", size: 30, relativeTo: .headline))
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        } title: {
            Text("Awesome Book")
        } subheadline: {
            Text("This a nice book recommendation")
        }
    }
}

#Preview {
    List {
        TileHeader(alignment: .trailing) {
            Image(systemName: "book.pages.fill")
                .foregroundStyle(.teal)
                .font(.custom("Task Icon", size: 30, relativeTo: .headline))
                .dynamicTypeSize(...DynamicTypeSize.accessibility2)
        } title: {
            Text("Awesome Book")
        } subheadline: {
            Text("This a nice book recommendation")
        }
    }
}
#endif
