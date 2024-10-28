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
    public init<S: StringProtocol>(verbatim label: S, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(content: content) {
            Text(label)
        }
    }

    /// Create a new list row with a localized text label.
    /// - Parameters:
    ///   - label: The localized text label.
    ///   - content: The content view.
    @_disfavoredOverload
    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(content: content) {
            Text(label)
        }
    }
}


extension LabeledContent where Label == Text, Content == Text {
    /// Creates a labeled informational view.
    ///
    /// - Parameters:
    ///   - titleKey: The key for the view's localized title, that describes
    ///     the purpose of the view.
    ///   - value: The value being labeled.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: LocalizedStringResource, value: S) {
        self.init {
            Text(value)
        } label: {
            Text(titleKey)
        }
    }
    
    /// Creates a labeled informational view from a formatted value.
    /// - Parameters:
    ///   - titleKey: A string that describes the purpose of the view.
    ///   - value: The value being labeled.
    ///   - format: A format style to convert the underlying value to a string representation.
    @_disfavoredOverload
    public init<F: FormatStyle>(
        _ titleKey: LocalizedStringResource,
        value: F.FormatInput,
        format: F
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.init {
            Text(value, format: format)
        } label: {
            Text(titleKey)
        }
    }
}


#if DEBUG
#Preview { // swiftlint:disable:this closure_body_length
    List {
        LabeledContent(verbatim: "Hello") {
            Text(verbatim: "World")
        }

        LabeledContent("Hello World") {
            Text("There")
        }

        LabeledContent {
            Text("2")
        } label: {
            Text("Value")
            Text("The magic value")
        }

        HStack {
            LabeledContent(verbatim: "Device") {
                EmptyView()
            }
            Spacer()
            ProgressView()
        }

        HStack {
            LabeledContent(verbatim: "Device") {
                Text(verbatim: "World")
            }
            Spacer()
            ProgressView()
                .padding(.leading, 6)
        }

        HStack {
            LabeledContent(verbatim: "Long Device Name") {
                Text(verbatim: "Long Description")
            }
            Spacer()
            ProgressView()
                .padding(.leading, 4)
        }
    }
}
#endif
