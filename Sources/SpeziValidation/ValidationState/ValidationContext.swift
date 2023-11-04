//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The validation context managed by a validation state modifier.
///
/// The `ValidationContext` is the state managed by the ``ValidationState`` property wrapper.
/// It provides access to the ``ValidationEngine``s of all subviews by capturing them with
/// ``CapturedValidationState``.
///
/// You can use this structure to retrieve the state of all ``ValidationEngine``s of a subview or manually
/// initiate validation by calling ``validateSubviews(switchFocus:)``. E.g., when pressing on a submit button of a form.
public struct ValidationContext {
    private let entries: [CapturedValidationState]


    /// Indicates if all input is currently considered valid.
    ///
    /// Please refer to the documentation of ``ValidationEngine/inputValid``.
    @MainActor
    public var allInputValid: Bool {
        entries.allSatisfy { $0.inputValid }
    }

    /// Collects all failed validations from all subviews.
    ///
    /// Please refer to the documentation of ``ValidationEngine/validationResults``.
    @MainActor
    public var allValidationResults: [FailedValidationResult] {
        entries.reduce(into: []) { result, state in
            result.append(contentsOf: state.validationResults)
        }
    }

    /// Collects all failed validations from all subviews that should be displayed by UI components.
    ///
    /// Please refer to the documentation of ``ValidationEngine/displayedValidationResults``.
    @MainActor
    public var allDisplayedValidationResults: [FailedValidationResult] {
        entries.reduce(into: []) { result, state in
            result.append(contentsOf: state.displayedValidationResults)
        }
    }

    /// Flag that indicates if ``allDisplayedValidationResults`` returns any results.
    ///
    /// Please refer to the documentation of ``ValidationEngine/isDisplayingValidationErrors``.
    @MainActor
    public var isDisplayingValidationErrors: Bool {
        entries.contains { $0.isDisplayingValidationErrors }
    }
    

    init() {
        self.init(entries: [])
    }


    init(entries: [CapturedValidationState]) {
        self.entries = entries
    }


    @MainActor private func collectFailedValidations() -> [CapturedValidationState] {
        compactMap { state in
            state.runValidation()

            guard !state.inputValid else {
                return nil
            }

            return state
        }
    }

    /// Run the validation engines of all your subviews.
    ///
    /// If provided, the `FocusState` will be automatically set to the first field
    /// that reported a failed validation result.
    ///
    /// - Parameter switchFocus: Flag that controls the automatic focus switching mechanisms. Default turned on.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews(switchFocus: Bool = true) -> Bool {
        let failedFields = collectFailedValidations()

        if let field = failedFields.first {
            if switchFocus {
                // move focus to the first field that failed validation
                field.moveFocus()
            }

            return false
        }

        return true
    }
}


extension ValidationContext: Equatable {}


extension ValidationContext: Collection {
    public var startIndex: Int {
        entries.startIndex
    }

    public var endIndex: Int {
        entries.endIndex
    }

    public func index(after index: Int) -> Int {
        entries.index(after: index)
    }

    public subscript(position: Int) -> CapturedValidationState {
        entries[position]
    }
}
