//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Attach a leading description label to your content.
///
/// The `DescriptionGridRow` provides a layout to attach a leading description label to a content element
/// in a [`Grid`](https://developer.apple.com/documentation/swiftui/grid)-based layout.
public struct DescriptionGridRow<Description: View, Content: View>: View {
    private let description: Description
    private let content: Content
    
    
    public var body: some View {
        GridRow {
            description
                .gridColumnAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
            content
                .frame(maxWidth: .infinity)
        }
            .contentShape(Rectangle())
    }
    
    
    /// Creates a new ``DescriptionGridRow`` instance providing a layout to align a description next to content element in a `Grid`-based layout.
    /// - Parameters:
    ///   - description: The description `View` of the `DescriptionGridRow``
    ///   - content: The content `View` of the `DescriptionGridRow``
    public init(
        @ViewBuilder description: () -> Description,
        @ViewBuilder content: () -> Content
    ) {
        self.description = description()
        self.content = content()
    }
}


#if DEBUG
struct DescriptionGridRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
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
        }
            .padding(32)
    }
}
#endif
