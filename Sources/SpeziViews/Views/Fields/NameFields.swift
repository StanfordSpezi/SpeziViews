//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// ``NameFields`` provides two text fields in a grid layout that allow users to enter their given and family name and parses the results in a `PersonNameComponents` instance.
public struct NameFields<GivenNameLabel: View, FamilyNameLabel: View, FocusedField: Hashable>: View {
    public enum LocalizationDefaults {
        public static var givenName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: .init("First Name", bundle: .atURL(from: .module), comment: "Given name title"),
                placeholder: .init("Enter your first name ...", bundle: .atURL(from: .module), comment: "Given name placeholder")
            )
        }
        public static var familyName: FieldLocalizationResource {
            FieldLocalizationResource(
                title: .init("Last Name", bundle: .atURL(from: .module), comment: "Family name title"),
                placeholder: .init("Enter your last name ...", bundle: .atURL(from: .module), comment: "Family name placeholder")
            )
        }
    }

    private let givenNamePlaceholder: LocalizedStringResource
    private let familyNamePlaceholder: LocalizedStringResource

    private let givenNameLabel: GivenNameLabel
    private let familyNameLabel: FamilyNameLabel

    private let givenNameFocus: FieldFocus<FocusedField>?
    private let familyNameFocus: FieldFocus<FocusedField>?

    @Binding private var name: PersonNameComponents
    
    
    public var body: some View {
        Grid {
            NameFieldRow(givenNamePlaceholder, name: $name, for: \.givenName, content: .givenName, focus: givenNameFocus) {
                givenNameLabel
            }

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow(familyNamePlaceholder, name: $name, for: \.familyName, content: .familyName, focus: familyNameFocus) {
                familyNameLabel
            }
        }
    }


    /// ``NameFields`` provides two text fields in a grid layout that allow users to enter their given and family name and parses the results in a `PersonNameComponents` instance.
    ///
    /// The initializer allows developers to pass in additional `FocusState` information to control and observe the focus state from outside the view.
    /// - Parameters:
    ///   - name: Binding containing the `PersonNameComponents` parsed from the fields.
    ///   - givenNameField: The localization of the given name field.
    ///   - givenNameFieldIdentifier: The `FocusState` identifier of the given name field.
    ///   - familyNameField: The localization of the family name field.
    ///   - familyNameFieldIdentifier: The `FocusState` identifier of the family name field.
    ///   - focusedState: `FocusState` binding to control and observe the focus state from outside the view.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        name: Binding<PersonNameComponents>,
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        givenNameFieldIdentifier: FocusedField,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName,
        familyNameFieldIdentifier: FocusedField,
        focusedState: FocusState<FocusedField?>.Binding
    ) where GivenNameLabel == Text, FamilyNameLabel == Text {
        self.init(
            name: name,
            givenNamePlaceholder: givenNameField.placeholder,
            givenNameFieldIdentifier: givenNameFieldIdentifier,
            familyNamePlaceholder: familyNameField.placeholder,
            familyNameFieldIdentifier: familyNameFieldIdentifier,
            focusedState: focusedState
        ) { // swiftlint:disable:this vertical_parameter_alignment_on_call
            Text(givenNameField.title)
        } familyName: {
            Text(familyNameField.title)
        }
    }

    /// ``NameFields`` provides two text fields in a grid layout that allow users to enter their given and family name and parses the results in a `PersonNameComponents` instance.
    /// - Parameters:
    ///   - name: Binding containing the `PersonNameComponents` parsed from the fields.
    ///   - givenNameField: The localization of the given name field.
    ///   - familyNameField: The localization of the family name field.
    public init(
        name: Binding<PersonNameComponents>,
        givenNameField: FieldLocalizationResource = LocalizationDefaults.givenName,
        familyNameField: FieldLocalizationResource = LocalizationDefaults.familyName
    ) where GivenNameLabel == Text, FamilyNameLabel == Text, FocusedField == UUID {
        self._name = name
        self.givenNamePlaceholder = givenNameField.placeholder
        self.familyNamePlaceholder = familyNameField.placeholder
        self.givenNameLabel = Text(givenNameField.title)
        self.familyNameLabel = Text(familyNameField.title)
        self.givenNameFocus = nil
        self.familyNameFocus = nil
    }

    /// ``NameFields`` provides two text fields in a grid layout that allow users to enter their given and family name and parses the results in a `PersonNameComponents` instance.
    ///
    /// The initializer allows developers to pass in additional `FocusState` information to control and observe the focus state from outside the view.
    /// - Parameters:
    ///   - name: Binding containing the `PersonNameComponents` parsed from the fields.
    ///   - givenNamePlaceholder: The localization of the given name field placeholder.
    ///   - givenNameFieldIdentifier: The `FocusState` identifier of the given name field.
    ///   - familyNamePlaceholder: The localization of the family name field placeholder.
    ///   - familyNameFieldIdentifier: The `FocusState` identifier of the family name field.
    ///   - focusedState: `FocusState` binding to control and observe the focus state from outside the view.
    ///   - givenNameLabel: The label presented in front of the given name `TextField`.
    ///   - familyNameLabel: The label presented in front of the family name `TextField`.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        name: Binding<PersonNameComponents>,
        givenNamePlaceholder: LocalizedStringResource = LocalizationDefaults.givenName.placeholder,
        givenNameFieldIdentifier: FocusedField,
        familyNamePlaceholder: LocalizedStringResource = LocalizationDefaults.familyName.placeholder,
        familyNameFieldIdentifier: FocusedField,
        focusedState: FocusState<FocusedField?>.Binding,
        @ViewBuilder givenName givenNameLabel: () -> GivenNameLabel,
        @ViewBuilder familyName familyNameLabel: () -> FamilyNameLabel
    ) {
        self._name = name
        self.givenNamePlaceholder = givenNamePlaceholder
        self.familyNamePlaceholder = familyNamePlaceholder
        self.givenNameFocus = FieldFocus(focusedState: focusedState, fieldIdentifier: givenNameFieldIdentifier)
        self.familyNameFocus = FieldFocus(focusedState: focusedState, fieldIdentifier: familyNameFieldIdentifier)
        self.givenNameLabel = givenNameLabel()
        self.familyNameLabel = familyNameLabel()
    }
}


#if DEBUG
struct NameFields_Previews: PreviewProvider {
    @State private static var name = PersonNameComponents()
    
    
    static var previews: some View {
        NameFields(name: $name)
    }
}
#endif
