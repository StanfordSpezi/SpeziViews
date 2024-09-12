//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A `NameTextField` that always shows a description in front of the text field.
///
/// The `NameFieldRow` uses the `DescriptionGridRow` and is to be placed into a [Grid](https://developer.apple.com/documentation/swiftui/grid)
/// view to provide a description text in front of the ``NameTextField``.
///
/// Below is a short code example on how to collect both the given name and family name of a person within a SwiftUI `Form`.
/// ```swift
/// @State private var name = PersonNameComponents()
///
/// var body: some View {
///     Form {
///         Grid(horizontalSpacing: 15) { // optional horizontal spacing
///             NameFieldRow(name: $name, for: \.givenName) {
///                 Text(verbatim: "First")
///             } label: {
///                 Text(verbatim: "enter first name")
///             }
///
///             Divider()
///                 .gridCellUnsizedAxes(.horizontal)
///
///             NameFieldRow(name: $name, for: \.familyName) {
///                 Text(verbatim: "Last")
///             } label: {
///                 Text(verbatim: "enter last name")
///             }
///         }
///     }
/// }
/// ```
public struct NameFieldRow<Description: View, Label: View>: View {
    private let description: Description
    private let label: Label
    private let component: WritableKeyPath<PersonNameComponents, String?>

    @Binding private var name: PersonNameComponents


    public var body: some View {
        #if os(macOS)
        let isMacOS = true
        #else
        let isMacOS = false
        #endif
        if isMacOS, let label = label as? Text {
            NameTextField(name: $name, for: component, prompt: label) {
                description
            }
        } else {
            DescriptionGridRow {
                description
            } content: {
                NameTextField(name: $name, for: component) {
                    label
                }
            }
        }
    }


    /// Creates a name text field with a description label.
    /// - Parameters:
    ///   - description: The localized description label displayed before the text field.
    ///   - name: The name to display and edit.
    ///   - component: The `KeyPath` to the property of the provided `PersonNameComponents` to display and edit.
    ///   - label: A view that describes the purpose of the text field.
    public init(
        _ description: LocalizedStringResource,
        name: Binding<PersonNameComponents>,
        for component: WritableKeyPath<PersonNameComponents, String?>,
        @ViewBuilder label: () -> Label
    ) where Description == Text {
        self.init(name: name, for: component, description: { Text(description) }, label: label)
    }

    /// Creates a name text field with a description label.
    /// - Parameters:
    ///   - name: The name to display and edit.
    ///   - component: The `KeyPath` to the property of the provided `PersonNameComponents` to display and edit.
    ///   - description: The description label displayed before the text field.
    ///   - label: A view that describes the purpose of the text field.
    public init(
        name: Binding<PersonNameComponents>,
        for component: WritableKeyPath<PersonNameComponents, String?>,
        @ViewBuilder description: () -> Description,
        @ViewBuilder label: () -> Label
    ) {
        self._name = name
        self.component = component
        self.description = description()
        self.label = label()
    }
}


#if DEBUG
#Preview {
    @State var name = PersonNameComponents()
    return Grid(horizontalSpacing: 15) {
        NameFieldRow(name: $name, for: \.familyName) {
            Text(verbatim: "First")
        } label: {
            Text(verbatim: "enter first name")
        }

        Divider()
            .gridCellUnsizedAxes(.horizontal)

        NameFieldRow(name: $name, for: \.familyName) {
            Text(verbatim: "Last")
        } label: {
            Text(verbatim: "enter last name")
        }
    }
}
#Preview {
    @State var name = PersonNameComponents()
    return Form {
        Grid(horizontalSpacing: 15) {
            NameFieldRow(name: $name, for: \.givenName) {
                Text(verbatim: "First")
            } label: {
                Text(verbatim: "enter first name")
            }

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow(name: $name, for: \.familyName) {
                Text(verbatim: "Last")
            } label: {
                Text(verbatim: "enter last name")
            }
        }
    }
}
#endif
