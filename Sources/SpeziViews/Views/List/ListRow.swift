//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A key-value-based List row.
///
/// Display key-value-based row elements within a List that automatically adjust to the size constraints
/// of the current device.
///
/// Below is a short code example on how to implement a simple List row that shows the temperature for a given city.
///
/// - Note: For more information how this view adjusts to different dynamic type sizes, device orientations and
///     horizontal size classes, refer to the documentation of the underlying ``DynamicHStack`` view.
///
/// ```swift
/// /// Display the current temperature for a city.
/// struct TemperatureRow: View {
///     private let city: LocalizedStringResource
///     private let temperature: Int
///
///     var body: some View {
///         ListRow(city) {
///             Text(verbatim: "\(temperature) °C")
///         }
///     }
/// }
/// ```
///
public struct ListRow<Label: View, Content: View>: View { // swiftlint:disable:this file_types_order
    private let labeledContent: LabeledContent<Label, Content>

    public var body: some View {
        labeledContent
            .accessibilityElement(children: .combine)
    }


    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    public init<S: StringProtocol>(verbatim label: S, @ViewBuilder content: () -> Content) where Label == Text {
        self.labeledContent = .init(verbatim: label, content: content)
    }

    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ label: S, @ViewBuilder content: () -> Content) where Label == Text {
        self.labeledContent = .init(label, content: content)
    }

    /// Create a new list row with a localized text label.
    /// - Parameters:
    ///   - label: The localized text label.
    ///   - content: The content view.
    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.labeledContent = .init(label, content: content)
    }


    /// Create a new list row.
    /// - Parameters:
    ///   - label: The label view.
    ///   - content: The content view.
    public init(@ViewBuilder _ label: () -> Label, @ViewBuilder content: () -> Content) {
        self.labeledContent = LabeledContent(content: content, label: label)
    }
}


extension ListRow where Label == Text, Content == Text { // swiftlint:disable:this file_types_order
    /// Create a list row with a string value.
    /// - Parameters:
    ///   - titleKey: The localized label.
    ///   - value: The string value.
    public init<S: StringProtocol>(_ titleKey: LocalizedStringKey, value: S) {
        self.labeledContent = LabeledContent(titleKey, value: value)
    }

    /// Create a list row with a string value.
    /// - Parameters:
    ///   - titleKey: The localized label.
    ///   - value: The string value being labeled.
    @_disfavoredOverload
    public init<S: StringProtocol>(_ titleKey: LocalizedStringResource, value: S) {
        self.labeledContent = LabeledContent {
            Text(value)
        } label: {
            Text(titleKey)
        }
    }

    /// Create a list row with a string value.
    /// - Parameters:
    ///   - titleKey: The string label.
    ///   - value: The string value being labeled.
    public init<S1: StringProtocol, S2: StringProtocol>(_ title: S1, value: S2) {
        self.labeledContent = LabeledContent(title, value: value)
    }

    /// Creates a labeled list row from a formatted value.
    /// - Parameters:
    ///   - title: The localized label.
    ///   - value: The value being labeled.
    ///   - format: A format style to convert the underlying value to a string representation.
    public init<F: FormatStyle>(
        _ titleKey: LocalizedStringKey,
        value: F.FormatInput,
        format: F
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.labeledContent = LabeledContent(titleKey, value: value, format: format)
    }

    /// Creates a labeled list row from a formatted value.
    /// - Parameters:
    ///   - title: The localized label.
    ///   - value: The value being labeled.
    ///   - format: A format style to convert the underlying value to a string representation.
    @_disfavoredOverload
    public init<F: FormatStyle>(
        _ titleKey: LocalizedStringResource,
        value: F.FormatInput,
        format: F
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.labeledContent = LabeledContent {
            Text(value, format: format)
        } label: {
            Text(titleKey)
        }
    }

    /// Creates a labeled list row from a formatted value.
    /// - Parameters:
    ///   - title: The string label.
    ///   - value: The value being labeled.
    ///   - format: A format style to convert the underlying value to a string representation.
    public init<S: StringProtocol, F: FormatStyle>(
        _ title: S,
        value: F.FormatInput,
        format: F
    ) where F.FormatInput: Equatable, F.FormatOutput == String {
        self.labeledContent = LabeledContent(title, value: value, format: format)
    }
}


#if DEBUG
private struct PreviewList: View {
    @available(*, deprecated, message: "Propagate warnings.")
    var body: some View {
        List {
            ListRow(verbatim: "Hello") {
                Text(verbatim: "World")
            }

            HStack {
                ListRow(verbatim: "Device") {
                    EmptyView()
                }
                ProgressView()
            }

            HStack {
                ListRow(verbatim: "Device") {
                    Text(verbatim: "World")
                }
                ProgressView()
                    .padding(.leading, 6)
            }

            HStack {
                ListRow(verbatim: "Long Device Name") {
                    Text(verbatim: "Long Description")
                }
                ProgressView()
                    .padding(.leading, 4)
            }
        }
    }
}

#Preview {
    PreviewList()
}
#endif
