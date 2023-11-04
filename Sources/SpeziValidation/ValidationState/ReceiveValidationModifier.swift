//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


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
    /// - Note: This version of the modifier uses a [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState)
    ///     value of `Never`. Meaning, it will only capture validation modifier that do not specify a focus value.
    ///
    /// - Parameter state: The binding to the ``ValidationState``.
    /// - Returns: The modified view.
    public func receiveValidation(in state: ValidationState.Binding) -> some View {
        onPreferenceChange(CapturedValidationStateKey.self) { entries in
            state.wrappedValue = ValidationContext(entries: entries)
        }
    }
/*
 TODO: remove?
    /// Receive validation state of all subviews.
    ///
    /// By supplying a binding to your declared ``ValidationState`` property, you can receive all changes to the
    /// validation state of your child views.
    ///
    /// - Note: While this modifier collects all validation state with the respective focus state value type, it doesn't
    ///     require to supply a [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState)
    ///     and, therefore, doesn't automatically switch focus on a failed validation.
    ///     For more information refer to the ``SwiftUI/View/receiveValidation(in:focus:)`` modifier.
    ///
    /// - Parameter state: The binding to the ``ValidationState``.
    /// - Returns: The modified view.
    public func receiveValidation<Value>(in state: ValidationState<Value>.Binding) -> some View {
        onPreferenceChange(CapturedValidationStateKey<Value>.self) { entries in
            state.wrappedValue = ValidationContext(entries: entries)
        }
    }
    */
/*
    /// Receive validation state of all subviews.
    ///
    /// By supplying a binding to your declared ``ValidationState`` property, you can receive all changes to the
    /// validation state of your child views.
    ///
    /// This modifier uses the supplied [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState)
    /// binding to automatically set focus to the first field that failed validation, once you manually
    /// call ``ValidationContext/validateSubviews(switchFocus:)`` on your validation state property.
    ///
    /// - Parameters:
    ///   - state: The binding to the ``ValidationState``.
    ///   - focus: A [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState) binding that will
    ///     be used to automatically set focus to the first field that failed validation.
    /// - Returns: The modified view.
    public func receiveValidation<Value>(in state: ValidationState<Value>.Binding, focus: FocusState<Value?>.Binding) -> some View {
        onPreferenceChange(CapturedValidationStateKey<Value>.self) { entries in
            state.wrappedValue = ValidationContext(entries: entries, focus: focus)
        }
    }*/
}
