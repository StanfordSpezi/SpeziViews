//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct FieldFocus<FocusedField: Hashable>: DynamicProperty {
    let focusedState: FocusState<FocusedField?>.Binding
    let fieldIdentifier: FocusedField
}


struct NameFieldRow<Label: View, Placeholder: View, FocusedField: Hashable>: View {
    private let label: Label
    private let placeholder: Placeholder

    private let nameComponent: WritableKeyPath<PersonNameComponents, String?>
    private let contentType: UITextContentType

    private let fieldFocus: FieldFocus<FocusedField>?


    @Binding private var name: PersonNameComponents

    private var componentBinding: Binding<String> {
        Binding {
            name[keyPath: nameComponent] ?? ""
        } set: { newValue in
            name[keyPath: nameComponent] = newValue
        }
    }


    var body: some View {
        let row = DescriptionGridRow {
            label
        } content: {
            TextField(text: componentBinding) {
                placeholder
            }
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .textContentType(contentType)
        }

        if let fieldFocus {
            row
                .onTapFocus(
                    focusedField: fieldFocus.focusedState,
                    fieldIdentifier: fieldFocus.fieldIdentifier
                )
        } else {
            row
                .onTapFocus()
        }
    }


    init(
        _ placeholder: LocalizedStringResource,
        name: Binding<PersonNameComponents>,
        for nameComponent: WritableKeyPath<PersonNameComponents, String?>,
        content contentType: UITextContentType,
        @ViewBuilder label: () -> Label
    ) where FocusedField == UUID, Placeholder == Text {
        self.init(placeholder, name: name, for: nameComponent, content: contentType, focus: nil, label: label)
    }

    init(
        name: Binding<PersonNameComponents>,
        for nameComponent: WritableKeyPath<PersonNameComponents, String?>,
        content contentType: UITextContentType,
        @ViewBuilder label: () -> Label,
        @ViewBuilder placeholder: () -> Placeholder
    ) where FocusedField == UUID {
        self.init(name: name, for: nameComponent, content: contentType, focus: nil, label: label, placeholder: placeholder)
    }

    init(
        _ placeholder: LocalizedStringResource,
        name: Binding<PersonNameComponents>,
        for nameComponent: WritableKeyPath<PersonNameComponents, String?>,
        content contentType: UITextContentType,
        focus fieldFocus: FieldFocus<FocusedField>?,
        @ViewBuilder label: () -> Label
    ) where Placeholder == Text {
        self.init(name: name, for: nameComponent, content: contentType, focus: fieldFocus, label: label) {
            Text(placeholder)
        }
    }

    init(
        name: Binding<PersonNameComponents>,
        for nameComponent: WritableKeyPath<PersonNameComponents, String?>,
        content contentType: UITextContentType,
        focus fieldFocus: FieldFocus<FocusedField>?,
        @ViewBuilder label: () -> Label,
        @ViewBuilder placeholder: () -> Placeholder
    ) {
        self._name = name
        self.nameComponent = nameComponent
        self.contentType = contentType
        self.fieldFocus = fieldFocus
        self.label = label()
        self.placeholder = placeholder()
    }
}


#if DEBUG
struct NameFieldRow_Previews: PreviewProvider {
    @State private static var name = PersonNameComponents()

    static var previews: some View {
        Grid {
            NameFieldRow(name: $name, for: \.givenName, content: .givenName) {
                Text(verbatim: "Enter first name ...")
            } placeholder: {
                Text(verbatim: "First Name")
            }
        }
    }
}
#endif
