//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct ValidationContext: Equatable {
    let engine: ValidationEngine
    let input: String

    public init(engine: ValidationEngine, input: String) {
        self.engine = engine
        self.input = input
    }
}


// TODO: move!
extension Array where Element == ValidationContext {
    @MainActor
    private func collectFailedResults() -> [FailedResult<Never>] {
        // TODO whatever!
        //for hook in hooks.values {
        //    hook()
        //}

        compactMap { context in
            let engine = context.engine
            engine.runValidation(input: context.input)

            guard !engine.inputValid else {
                return nil
            }

            return FailedResult(validationEngineId: engine.id, failedFieldIdentifier: nil) // TODO: infrastructure!
        }
        /*
         engine.runValidation(input: input)

         guard !engine.inputValid else {
         return nil
         }

         return FailedResult(validationEngineId: engine.id, failedFieldIdentifier: fieldIdentifier)
         */
    }
/* TODO: asdf
    /// Run the validation engines of all your subviews
    ///
    /// - Parameter focusState: The first failed field will receive focus.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews(focusState: FocusState<FieldIdentifier?>.Binding) -> Bool {
        let results = collectFailedResults()

        if let firstFailedField = results.first {
            if let fieldIdentifier = firstFailedField.failedFieldIdentifier {
                focusState.wrappedValue = fieldIdentifier
            }

            return false
        }

        return true
    }*/

    /// Run the validation engines of all your subviews without setting a focus state.
    /// - Returns: Returns `true` if all subviews reported valid data. Returns `false` if at least one
    ///     subview reported invalid data.
    @MainActor
    @discardableResult
    public func validateSubviews() -> Bool {
        collectFailedResults().isEmpty
    }
}
