//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ValidationModifier<FocusValue: Hashable>: ViewModifier {
    private let input: String
    private let fieldIdentifier: FocusValue?

    @Environment(\.validationConfiguration) private var configuration
    @Environment(\.validationDebounce) private var debounce

    @State private var validation: ValidationEngine

    init(input: String, field fieldIdentifier: FocusValue?, rules: [ValidationRule]) {
        self.input = input
        self.fieldIdentifier = fieldIdentifier
        self._validation = State(wrappedValue: ValidationEngine(rules: rules))
    }

    func body(content: Content) -> some View {
        content
            .environment(validation)
            .preference(
                key: CapturedValidationStateKey<FocusValue>.self,
                value: [CapturedValidationState(engine: validation, input: input, field: fieldIdentifier)]
            )
            .onChange(of: configuration, initial: true) {
                validation.configuration = configuration
            }
            .onChange(of: debounce, initial: true) {
                validation.debounceDuration = debounce
            }
            .onChange(of: input) {
                validation.submit(input: input, debounce: true)
            }
            .onSubmit(of: .text) {
                // here we just make sure that we submit it without a debounce
                validation.submit(input: input)
            }
    }
}

extension View {
    /// Validate an input against a set of validation rules.
    ///
    /// This modifier can be used to validate a `String` input against a set of ``ValidationRule``s.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment. The modifier automatically calls ``ValidationEngine/submit(input:debounce:)`` on a change of the input.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate(input value: String, rules: [ValidationRule]) -> some View {
        modifier(ValidationModifier<Never>(input: value, field: nil, rules: rules))
    }

    /// Validate an input against a set of validation rules.
    ///
    /// This modifier can be used to validate a `String` input against a set of ``ValidationRule``s.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment. The modifier automatically calls ``ValidationEngine/submit(input:debounce:)`` on a change of the input.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate(input value: String, rules: ValidationRule...) -> some View {
        validate(input: value, rules: rules)
    }

    /// Validate an input against a set of validation rules with automatic focus management.
    ///
    /// This modifier can be used to validate a `String` input against a set of ``ValidationRule``s.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment. The modifier automatically calls ``ValidationEngine/submit(input:debounce:)`` on a change of the input.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate<FocusValue: Hashable>(
        input value: String,
        field fieldIdentifier: FocusValue,
        rules: [ValidationRule]
    ) -> some View {
        modifier(ValidationModifier(input: value, field: fieldIdentifier, rules: rules))
    }

    /// Validate an input against a set of validation rules with automatic focus management.
    ///
    /// This modifier can be used to validate a `String` input against a set of ``ValidationRule``s.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment. The modifier automatically calls ``ValidationEngine/submit(input:debounce:)`` on a change of the input.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - fieldIdentifier: The field identifier of the field that receives focus if validation fails.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate<FocusValue: Hashable>(
        input value: String,
        field fieldIdentifier: FocusValue,
        rules: ValidationRule...
    ) -> some View {
        validate(input: value, field: fieldIdentifier, rules: rules)
    }
}
