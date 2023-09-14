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


struct NameFieldRow<Label: View, FocusedField: Hashable>: View {
    private let label: Label
    private let placeholder: LocalizedStringResource

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
                Text(placeholder)
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
    ) where FocusedField == UUID {
        self.init(placeholder, name: name, for: nameComponent, content: contentType, focus: nil, label: label)
    }

    init(
        _ placeholder: LocalizedStringResource,
        name: Binding<PersonNameComponents>,
        for nameComponent: WritableKeyPath<PersonNameComponents, String?>,
        content contentType: UITextContentType,
        focus fieldFocus: FieldFocus<FocusedField>?,
        @ViewBuilder label: () -> Label
    ) {
        self.placeholder = placeholder
        self._name = name
        self.nameComponent = nameComponent
        self.contentType = contentType
        self.fieldFocus = fieldFocus
        self.label = label()
    }
}


#if DEBUG
struct NameFieldRow_Previews: PreviewProvider {
    @State private static var name = PersonNameComponents()

    static var previews: some View {
        Grid {
            NameFieldRow("First Name", name: $name, for: \.givenName, content: .givenName) {
                Text("Enter first name ...")
            }
        }
    }
}
#endif
