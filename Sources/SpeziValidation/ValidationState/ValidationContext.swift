//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct FailedFieldResult<FocusValue> {
    let field: FocusValue? // we store an optional as it might be Never
}


public struct ValidationContext<FocusValue: Hashable> {
    private let entries: [CapturedValidationState<FocusValue>]
    private let focusState: FocusState<FocusValue?>.Binding?


    /// Indicates if all input is currently considered valid.
    ///
    /// Please refer to the documentation of ``ValidationEngine/inputValid``.
    @MainActor
    public var inputValid: Bool {
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
    

    init() {
        self.init(entries: [])
    }


    init(entries: [CapturedValidationState<FocusValue>], focus: FocusState<FocusValue?>.Binding? = nil) {
        self.entries = entries
        self.focusState = focus
    }


    @MainActor private func collectFailedFields() -> [FailedFieldResult<FocusValue>] {
        compactMap { state in
            state.runValidation()

            guard !state.inputValid else {
                return nil
            }

            return FailedFieldResult(field: state.fieldIdentifier)
        }
    }

    /// Run the validation engines of all your subviews.
    ///
    /// If provided, the `FocusState` will be automatically set to the first field
    /// that reported a failed validation result.
    ///
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews() -> Bool {
        let failedFields = collectFailedFields()

        if let first = failedFields.first {
            if let focusState,
               let field = first.field {
                focusState.wrappedValue = field
            }

            return false
        }

        return true
    }
}


extension ValidationContext: Equatable {
    public static func == (lhs: ValidationContext<FocusValue>, rhs: ValidationContext<FocusValue>) -> Bool {
        lhs.entries == rhs.entries
            && ((lhs.focusState == nil && rhs.focusState == nil) || (lhs.focusState != nil && rhs.focusState != nil))
    }
}


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

    public subscript(position: Int) -> CapturedValidationState<FocusValue> {
        entries[position]
    }
}
