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
public struct ListRow<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content

    @State private var alignment: Alignment?


    public var body: some View {
        HStack {
            DynamicHStack {
                label
                    .foregroundColor(.primary)
                    .lineLimit(alignment == .horizontal ? 1 : nil)

                if alignment == .horizontal {
                    Spacer()
                }

                content
                    .lineLimit(alignment == .horizontal ? 1 : nil)
                    .layoutPriority(1)
                    .foregroundColor(.secondary)
            }

            if alignment == .vertical {
                Spacer()
            }
        }
            // .accessibilityElement(children: .combine)
            .onPreferenceChange(Alignment.self) { value in
                alignment = value
            }
    }


    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    public init(verbatim label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init(label, content: content)
    }

    /// Create a new list row with a string label.
    /// - Parameters:
    ///   - label: The string label.
    ///   - content: The content view.
    @_disfavoredOverload
    public init(_ label: String, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(verbatim: label) }, content: content)
    }

    /// Create a new list row with a localized text label.
    /// - Parameters:
    ///   - label: The localized text label.
    ///   - content: The contet view.
    public init(_ label: LocalizedStringResource, @ViewBuilder content: () -> Content) where Label == Text {
        self.init({ Text(label) }, content: content)
    }


    /// Create a new list row.
    /// - Parameters:
    ///   - label: The label view.
    ///   - content: The content view.
    public init(@ViewBuilder _ label: () -> Label, @ViewBuilder content: () -> Content) {
        self.label = label()
        self.content = content()
    }
}


#if DEBUG
#Preview {
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
#endif
