//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct UUIDOnTapFocus: ViewModifier {
    @FocusState var focusedState: UUID?

    func body(content: Content) -> some View {
        content
            .onTapFocus(focusedField: $focusedState, fieldIdentifier: UUID())
    }
}


private struct OnTapFocus<FocusedField: Hashable>: ViewModifier {
    private let fieldIdentifier: FocusedField

    @FocusState.Binding var focusedState: FocusedField?
    
    init(
        focusedState: FocusState<FocusedField?>.Binding,
        fieldIdentifier: FocusedField
    ) {
        self._focusedState = focusedState
        self.fieldIdentifier = fieldIdentifier
    }
    
    
    func body(content: Content) -> some View {
        content
            .focused($focusedState, equals: fieldIdentifier)
            .onTapGesture {
                focusedState = fieldIdentifier
            }
    }
}


extension View { // TODO document usefulness!
    /// Modifies the view to be in a focused state (e.g., `TextFields`) if it is tapped.
    public func onTapFocus() -> some View {
        modifier(UUIDOnTapFocus())
    }

    /// Modifies the view to be in a focused state (e.g., `TextFields`) if it is tapped.
    /// - Parameters:
    ///   - focusedField: The `FocusState` binding that should be set.
    ///   - fieldIdentifier: The identifier that the `focusedField` should be set to.
    public func onTapFocus<FocusedField: Hashable>(
        focusedField: FocusState<FocusedField?>.Binding,
        fieldIdentifier: FocusedField
    ) -> some View {
        modifier(OnTapFocus(focusedState: focusedField, fieldIdentifier: fieldIdentifier))
    }
}
