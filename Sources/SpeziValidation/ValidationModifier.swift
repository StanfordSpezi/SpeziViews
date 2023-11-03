//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ValidationModifier<FieldIdentifier: Hashable>: ViewModifier {
    private let inputValue: String
    private let fieldIdentifier: FieldIdentifier?

    @Environment(\.validationEngineConfiguration) private var configuration // TODO allow to specify configuration inside?

    @State private var validation: ValidationEngine

    init(input value: String, for fieldIdentifier: FieldIdentifier?, rules: [ValidationRule]) {
        self.inputValue = value
        self.fieldIdentifier = fieldIdentifier
        self._validation = State(wrappedValue: ValidationEngine(rules: rules))
    }

    func body(content: Content) -> some View {
        let _ = validation.configuration = configuration // swiftlint:disable:this redundant_discardable_let

        content
            .environment(validation)
            .preference(key: ConfiguredValidationEngines.self, value: [ValidationContext(engine: validation, input: inputValue)])
    }
}


extension View {
    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation<FieldIdentifier: Hashable>(
        input value: String,
        for fieldIdentifier: FieldIdentifier,
        rules: [ValidationRule]
    ) -> some View {
        modifier(ValidationModifier(input: value, for: fieldIdentifier, rules: rules))
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate( // TODO rethink whole thing about docs and naming in this extension
        input value: String,
        rules: [ValidationRule]
    ) -> some View {
        modifier(ValidationModifier<Never>(input: value, for: nil, rules: rules))
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation<FieldIdentifier: Hashable>(
        input value: String,
        for fieldIdentifier: FieldIdentifier,
        rules: ValidationRule...
    ) -> some View {
        managedValidation(input: value, for: fieldIdentifier, rules: rules)
    }

    /// Automatically manage a ``ValidationEngine`` object.
    ///
    /// This modified creates and manages a ``ValidationEngine`` object and places it into the environment for subviews.
    ///
    /// The modifier can be used in ``DataEntryView``s or other views where a ``ValidationEngines`` object is present in the environment.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func managedValidation(
        input value: String,
        rules: ValidationRule...
    ) -> some View {
        validate(input: value, rules: rules)
    }
}
