//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@propertyWrapper
public struct ValidationState<FocusValue: Hashable>: DynamicProperty {
    @State private var state = ValidationContext<FocusValue>()

    public var wrappedValue: ValidationContext<FocusValue> {
        state
    }

    public var projectedValue: ValidationState<FocusValue>.Binding {
        Binding(binding: $state)
    }


    public init() where FocusValue == Never {}

    public init(_ focusValueType: FocusValue.Type = FocusValue.self) where FocusValue: Hashable {}
}


extension ValidationState {
    @propertyWrapper
    public struct Binding {
        private let binding: SwiftUI.Binding<ValidationContext<FocusValue>>

        public var wrappedValue: ValidationContext<FocusValue> {
            get {
                binding.wrappedValue
            }
            nonmutating set {
                binding.wrappedValue = newValue
            }
        }

        public var projectedValue: Binding {
            self
        }

        
        init(binding: SwiftUI.Binding<ValidationContext<FocusValue>>) {
            self.binding = binding
        }
    }
}
