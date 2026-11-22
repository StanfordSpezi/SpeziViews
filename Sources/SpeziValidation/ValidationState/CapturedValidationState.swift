//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A momentary snapshot of the current validation state of a view.
///
/// This structure provides context to a particular ``ValidationEngine`` instance by capturing it's input
/// and optionally a [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState) value.
///
/// This particularly allows to run a validation from the outside of a view.
@dynamicMemberLookup
@MainActor
public struct CapturedValidationState {
    nonisolated private let engine: ValidationEngine
    nonisolated private let input: String
    private let focusState: FocusState<Bool>.Binding

    init(engine: ValidationEngine, input: String, focus focusState: FocusState<Bool>.Binding) {
        self.engine = engine
        self.input = input
        self.focusState = focusState
    }

    /// Moves focus to this field.
    func moveFocus() {
        focusState.wrappedValue = true
    }

    /// Execute the validation engine for the current state of the captured view.
    @MainActor public func runValidation() {
        engine.runValidation(input: input)
    }

    /// Access properties of the underlying ``ValidationEngine``.
    /// - Parameter keyPath: The key path into the validation engine.
    /// - Returns: The value of the property.
    public subscript<Value>(dynamicMember keyPath: KeyPath<ValidationEngine, Value>) -> Value {
        engine[keyPath: keyPath]
    }
}


extension CapturedValidationState: Equatable, Sendable {
    nonisolated public static func == (lhs: CapturedValidationState, rhs: CapturedValidationState) -> Bool {
        lhs.engine === rhs.engine && lhs.input == rhs.input
    }
}
