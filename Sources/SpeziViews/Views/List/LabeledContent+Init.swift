//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension LabeledContent where Content: View {
    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    @_disfavoredOverload
    public init(_ label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(verbatim: label, content: content)
    }

    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    public init(verbatim label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(content: content) {
            Text(label)
        }
    }

    /// Create a new list row with a localized text label.
    /// - Parameters:
    ///   - label: The localized text label.
    ///   - content: The content view.
    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(content: content) {
            Text(label)
        }
    }
}


#if DEBUG
#Preview {
    List {
        LabeledContent(verbatim: "Hello") {
            Text(verbatim: "World")
        }

        HStack {
            LabeledContent(verbatim: "Device") {
                EmptyView()
            }
            ProgressView()
        }

        HStack {
            LabeledContent(verbatim: "Device") {
                Text(verbatim: "World")
            }
            ProgressView()
                .padding(.leading, 6)
        }

        HStack {
            LabeledContent(verbatim: "Long Device Name") {
                Text(verbatim: "Long Description")
            }
            ProgressView()
                .padding(.leading, 4)
        }
    }
}
#endif
