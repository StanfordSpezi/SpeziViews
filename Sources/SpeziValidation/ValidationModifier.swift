//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ValidationModifier: ViewModifier {
    private let input: String

    @Environment(\.validationConfiguration) private var configuration
    @Environment(\.validationDebounce) private var debounce

    @State private var validation: ValidationEngine
    @FocusState private var hasFocus: Bool

    init(input: String, rules: [ValidationRule]) {
        self.input = input
        self._validation = State(wrappedValue: ValidationEngine(rules: rules))
    }

    func body(content: Content) -> some View {
        content
            .environment(validation)
            .focused($hasFocus)
            .preference(
                key: CapturedValidationStateKey.self,
                value: [CapturedValidationState(engine: validation, input: input, focus: $hasFocus)]
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
    /// environment.
    ///
    /// Below is a short code example on how to use the modifier. We rely on ``VerifiableTextField`` to visualize potential validation errors.
    /// ```swift
    /// @State var phrase: String = ""
    ///
    /// var body: some View {
    ///     Form {
    ///         VerifiableTextField("your favorite phrase", text: $phrase)
    ///             .validate(input: phrase, rules: .nonEmpty)
    ///     }
    /// }
    /// ```
    ///
    /// - Important: You shouldn't place multiple validate modifiers into the same view hierarchy branch. This creates
    ///     visibility problems in both direction. Both displaying validation results in the child view and receiving
    ///     validation state from the parent view.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - rules: An array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate(input value: String, rules: [ValidationRule]) -> some View {
        modifier(ValidationModifier(input: value, rules: rules))
    }

    /// Validate an input against a set of validation rules.
    ///
    /// This modifier can be used to validate a `String` input against a set of ``ValidationRule``s.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment.
    ///
    /// Below is a short code example on how to use the modifier. We rely on ``VerifiableTextField`` to visualize potential validation errors.
    /// ```swift
    /// @State var phrase: String = ""
    ///
    /// var body: some View {
    ///     Form {
    ///         VerifiableTextField("your favorite phrase", text: $phrase)
    ///             .validate(input: phrase, rules: .nonEmpty)
    ///     }
    /// }
    /// ```
    ///
    /// - Important: You shouldn't place multiple validate modifiers into the same view hierarchy branch. This creates
    ///     visibility problems in both direction. Both displaying validation results in the child view and receiving
    ///     validation state from the parent view.
    ///
    /// - Parameters:
    ///   - value: The current value to validate.
    ///   - rules: An variadic array of ``ValidationRule``s.
    /// - Returns: The modified view.
    public func validate(input value: String, rules: ValidationRule...) -> some View {
        validate(input: value, rules: rules)
    }


    /// Validate a `Bool` expression.
    ///
    /// This modifier can be used to validate a `Bool` predicate. If the expression doesn't evaluate to `true`, the `message`
    /// is shown as a validation error.
    ///
    /// Validation is managed through a ``ValidationEngine`` instance that is injected as an `Observable` into the
    /// environment.
    ///
    /// Below is an example that uses the `validate(_:message:)` modifier to validate the selection of a `Picker`.
    /// - Note: The example uses the ``receiveValidation(in:)`` modifier to retrieve the validation results of the subview.
    ///     The ``ValidationResultsView`` is used to render the failure reason in red text below the picker.
    ///
    /// ```swift
    /// struct MyView: View {
    ///     enum Selection: String, CaseIterable, Hashable {
    ///         case none = "Nothing selected"
    ///         case accept = "Accept"
    ///         case deny = "Deny"
    ///     }
    ///
    ///     @State private var selection: Selection = .none
    ///     @ValidationState private var validationState
    ///
    ///     var body: some View {
    ///         VStack(alignment: .leading) {
    ///             Picker(selection: $selection) {
    ///                 ForEach(Selection.allCases, id: \.rawValue) { selection in
    ///                     Text(selection.rawValue)
    ///                         .tag(selection)
    ///                 }
    ///             } label: {
    ///                 Text("Cookies")
    ///             }
    ///             ValidationResultsView(results: validationState.allDisplayedValidationResults)
    ///         }
    ///             .validate(selection != .none, message: "This field must be selected")
    ///             .receiveValidation(in: $validationState)
    ///     }
    /// }
    /// ```
    ///
    /// - Important: You shouldn't place multiple validate modifiers into the same view hierarchy branch. This creates
    ///     visibility problems in both direction. Both displaying validation results in the child view and receiving
    ///     validation state from the parent view.
    ///
    /// - Parameters:
    ///   - predicate: The predicate to validate.
    ///   - message: The validation message that is used as an failure reason, if the predicate evaluates to `false`.
    /// - Returns: The modified view.
    public func validate(_ predicate: Bool, message: LocalizedStringResource) -> some View {
        let rule = ValidationRule(rule: { $0.isEmpty }, message: message)
        return validate(input: predicate ? "" : "FALSE", rules: [rule])
    }
}
