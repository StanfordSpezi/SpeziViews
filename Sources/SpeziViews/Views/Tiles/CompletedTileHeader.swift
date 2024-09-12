//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A tile header that signifies a completed action.
///
/// ```swift
/// SimpleTile {
///     CompletedTileHeader {
///         Text("Weight Measurement")
///     }
/// }
/// ```
public struct CompletedTileHeader<Title: View>: View {
    private let alignment: HorizontalAlignment
    private let title: Title

    public var body: some View {
        TileHeader(alignment: alignment) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.custom("Completed Icon", size: 30, relativeTo: .title))
                .accessibilityHidden(true)
        } title: {
            title
        } subheadline: {
            Text("Completed", bundle: .module, comment: "Completed Tile. Subtitle")
        }
    }
    
    /// Create a new completed tile header.
    /// - Parameter title: The view that is shown as the title.
    public init(alignment: HorizontalAlignment = .leading, @ViewBuilder title: () -> Title) {
        self.alignment = alignment
        self.title = title()
    }
}


#if DEBUG
#Preview {
    List {
        CompletedTileHeader {
            Text(verbatim: "Test Task")
        }
    }
}
#endif
