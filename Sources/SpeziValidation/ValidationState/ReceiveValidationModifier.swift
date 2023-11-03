//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct CapturedValidationStateKey<FocusValue>: PreferenceKey {
    static var defaultValue: [CapturedValidationState<FocusValue>] {
        []
    }

    static func reduce(value: inout [CapturedValidationState<FocusValue>], nextValue: () -> [CapturedValidationState<FocusValue>]) {
        value.append(contentsOf: nextValue())
    }
}


extension View {
    public func receiveValidation(in state: ValidationState<Never>.Binding) -> some View {
        onPreferenceChange(CapturedValidationStateKey<Never>.self) { entries in
            state.wrappedValue = ValidationContext(entries: entries)
        }
    }

    public func receiveValidation<Value>(in state: ValidationState<Value>.Binding, focus: FocusState<Value?>.Binding) -> some View {
        onPreferenceChange(CapturedValidationStateKey<Value>.self) { entries in
            state.wrappedValue = ValidationContext(entries: entries, focus: focus)
        }
    }
}
