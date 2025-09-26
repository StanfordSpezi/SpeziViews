//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


/// A TextField for properties of `PersonNameComponents`.
///
/// The `NameTextField` view allows to create a SwiftUI [TextField](https://developer.apple.com/documentation/swiftui/textfield) for properties
/// of [PersonNameComponents](https://developer.apple.com/documentation/foundation/personnamecomponents).
/// To do so you supply a Binding to your `PersonNameComponents` value and a `KeyPath` to the property of `PersonNameComponents` you are trying to input.
///
/// `NameTextField` modifies the underlying `TextField` to optimize for name entry and automatically sets modifiers like
/// [textContentType(_:)](https://developer.apple.com/documentation/swiftui/view/textcontenttype(_:)-ufdv).
///
/// Below is a short code example on how to create an editable text interface for the given name of a person.
/// ```swift
/// @State private var name = PersonNameComponents()
///
/// var body: some View {
///     NameTextField("enter first name", name: $name, for: \.givenName)
/// }
/// ```
///
/// - Note: A empty string will be automatically mapped to a `nil` value for the respective property of `PersonNameComponents`.
public struct NameTextField<Label: View>: View {
    private let prompt: Text?
    private let label: Label
    private let nameComponent: WritableKeyPath<PersonNameComponents, String?>

    @Binding private var name: PersonNameComponents

    private var componentBinding: Binding<String> {
        Binding {
            name[keyPath: nameComponent] ?? ""
        } set: { newValue in
            name[keyPath: nameComponent] = newValue.isEmpty ? nil : newValue
        }
    }

    private var contentType: TextContentType {
        switch nameComponent {
        case \.namePrefix:
            return .namePrefix
        case \.nameSuffix:
            return .nameSuffix
        case \.givenName:
            return .givenName
        case \.middleName:
            return .middleName
        case \.familyName:
            return .familyName
        case \.nickname:
            return .nickname
        default:
            return .name // general, catch all content type
        }
    }

    @_documentation(visibility: internal)
    public var body: some View {
        TextField(text: componentBinding, prompt: prompt) {
            label
        }
            .autocorrectionDisabled()
            #if !os(macOS)
            .textInputAutocapitalization(.words)
            #endif
            .textContentType(contentType)
    }


    /// Creates a name text field with an optional prompt.
    /// - Parameters:
    ///   - label: A localized title of the text field, describing its purpose.
    ///   - name: The name to display and edit.
    ///   - component: The `KeyPath` to the property of the provided `PersonNameComponents` to display and edit.
    ///   - prompt: An optional `Text` prompt. Refer to the documentation of `TextField` for more information.
    public init(
        _ label: LocalizedStringResource,
        name: Binding<PersonNameComponents>,
        for component: WritableKeyPath<PersonNameComponents, String?>,
        prompt: Text? = nil
    ) where Label == Text {
        self.init(name: name, for: component, prompt: prompt) {
            Text(label)
        }
    }

    /// Creates a name text field with an optional prompt.
    /// - Parameters:
    ///   - name: The name to display and edit.
    ///   - component: The `KeyPath` to the property of the provided `PersonNameComponents` to display and edit.
    ///   - prompt: An optional `Text` prompt. Refer to the documentation of `TextField` for more information.
    ///   - label: A view that describes the purpose of the text field.
    public init(
        name: Binding<PersonNameComponents>,
        for component: WritableKeyPath<PersonNameComponents, String?>,
        prompt: Text? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self._name = name
        self.nameComponent = component
        self.prompt = prompt
        self.label = label()
    }
}


#if DEBUG
#Preview {
    @Previewable @State var name = PersonNameComponents()
    return List {
        NameTextField(name: $name, for: \.givenName) {
            Text(verbatim: "enter first name")
        }
    }
}
#endif
