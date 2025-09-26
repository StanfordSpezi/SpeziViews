//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A tile-like view with header, footer and an optional action.
///
/// Below is a code example on how to use a tile view with specifying a body and a footer.
///
/// ```swift
/// SimpleTile {
///     Text("Clean Code")
/// } body: {
///     Text("A book by Robert C. Martin")
/// } footer: {
///     Button {
///         let url = URL(string: "https://www.mitp.de/IT-WEB/Programmierung/Clean-Code.html")!
///         UIApplication.shared.open(url)
///     } label: {
///         Text("Buy")
///             .frame(maxWidth: .infinity, minHeight: 30)
///     }
///         .buttonStyle(.borderedProminent)
/// }
/// ```
///
/// A tile can be rendered with three different layouts: `leading`, `center` and `trailing`.
///
/// @Row {
///     @Column {
///         @Image(source: "Tile-Leading", alt: "A `SimpleTile` view with a `TileHeader` view with `leading` alignment.") {
///             Using the `SimpleTile` view with the default ``TileHeader`` and `leading` alignment.
///         }
///     }
///     @Column {
///     @Image(source: "Tile-Center", alt: "A `SimpleTile` view with a `TileHeader` view with `center` alignment.") {
///             Using the `SimpleTile` view with the default ``TileHeader`` and `center` alignment.
///         }
///     }
///     @Column {
///         @Image(source: "Tile-Trailing", alt: "A `SimpleTile` view with a `TileHeader` view with `center` alignment.") {
///             Using the `SimpleTile` view with the default ``TileHeader`` and `trailing` alignment.
///         }
///     }
/// }
public struct SimpleTile<Header: View, Body: View, Footer: View>: View {
    private let alignment: HorizontalAlignment
    private let header: Header
    private let bodyView: Body
    private let footer: Footer

    @_documentation(visibility: internal)
    public var body: some View {
        VStack(alignment: alignment) {
            header

            if Body.self != EmptyView.self || Footer.self != EmptyView.self {
                Divider()
                    .padding(.bottom, 4)
            }

            bodyView

            footer
                .if(Body.self != EmptyView.self) { footer in
                    footer
                        .padding(.top, 8)
                }
        }
            .containerShape(Rectangle())
#if !TEST && !targetEnvironment(simulator) // it's easier to UI test for us without the accessibility representation
            .accessibilityElement(children: .combine)
#endif
    }
    
    /// Create a new tile view.
    /// - Parameters:
    ///   - alignment: The alignment of the tile.
    ///   - header: The header view of the tile. Refer to ``TileHeader`` for a great default layout for tile headers.
    ///   - body: The body of the tile.
    ///   - footer: A footer that can be used to place buttons or other actions.
    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder header: () -> Header,
        @ViewBuilder body: () -> Body = { EmptyView() },
        @ViewBuilder footer: () -> Footer
    ) {
        self.alignment = alignment
        self.header = header()
        self.bodyView = body()
        self.footer = footer()
    }

    /// Create a new tile view.
    /// - Parameters:
    ///   - alignment: The alignment of the tile.
    ///   - header: The header view of the tile. Refer to ``TileHeader`` for a great default layout for tile headers.
    ///   - body: The body of the tile.
    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder header: () -> Header,
        @ViewBuilder body: () -> Body
    ) where Footer == EmptyView {
        self.init(alignment: alignment, header: header, body: body) {
            EmptyView()
        }
    }

    /// Create a new tile view.
    /// - Parameters:
    ///   - alignment: The alignment of the tile.
    ///   - header: The header view of the tile. Refer to ``TileHeader`` for a great default layout for tile headers.
    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder header: () -> Header
    ) where Body == EmptyView, Footer == EmptyView {
        self.init(alignment: alignment, header: header) {
            EmptyView()
        }
    }
}


#if DEBUG
#Preview {
    List {
        SimpleTile {
            Text(verbatim: "Test Tile Header")
        } body: {
            Text(verbatim: "The description of a tile")
        } footer: {
            Button {
                print("Action pressed")
            } label: {
                Text("Action")
                    .frame(maxWidth: .infinity, minHeight: 30)
            }
                .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    List {
        SimpleTile {
            Text(verbatim: "Test Tile Header")
        } body: {
            Text(verbatim: "The description of a tile")
        }
    }
}

#Preview {
    List {
        SimpleTile {
            Text(verbatim: "Test Tile Header only")
        }
    }
}
#endif
