//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@MainActor
private struct IsolatedValidationBinding: Sendable {
    let state: ValidationState.Binding

    init(_ state: ValidationState.Binding) {
        self.state = state
    }
}


/// Provide access to validation state to the parent view.
///
/// The internal preference key to provide parent views access to all configured ``ValidationEngine`` and input
/// state by capturing it into a ``CapturedValidationState``.
struct CapturedValidationStateKey: PreferenceKey {
    static var defaultValue: [CapturedValidationState] {
        []
    }

    static func reduce(value: inout [CapturedValidationState], nextValue: () -> [CapturedValidationState]) {
        value.append(contentsOf: nextValue())
    }
}


extension View {
    /// Receive validation state of all subviews.
    ///
    /// By supplying a binding to your declared ``ValidationState`` property, you can receive all changes to the
    /// validation state of your child views.
    ///
    /// When calling the ``ValidationContext/validateSubviews(switchFocus:)`` focus automatically switches to the
    /// first field that failed validation.
    ///
    /// - Parameter state: The binding to the ``ValidationState``.
    /// - Returns: The modified view.
    public func receiveValidation(in state: ValidationState.Binding) -> some View {
        let binding = IsolatedValidationBinding(state)

        return onPreferenceChange(CapturedValidationStateKey.self) { entries in
            Task { @Sendable @MainActor in
                binding.state.wrappedValue = ValidationContext(entries: entries)
            }
        }
    }
}
