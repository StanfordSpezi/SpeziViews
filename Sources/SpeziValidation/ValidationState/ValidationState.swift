//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// It provides access to the ``ValidationEngine``s of all subviews by capturing them with
/// ``CapturedValidationState``.
///
/// You can use this structure to retrieve the state of all ``ValidationEngine``s of a subview or manually
/// initiate validation by calling ``validateSubviews(switchFocus:)``. E.g., when pressing on a submit button of a form.


/// Property wrapper to retrieve validation state of all subviews.
///
/// The `ValidationState` property wrapper can be used to retrieve the validation state of
/// all subviews and manually initiate validation (e.g., when pressing the submit button of a form).
///
/// The `ValidationState` property wrapper works in conjunction with the ``SwiftUI/View/receiveValidation(in:)` modifier
/// to receive all validation state from the child views.
///
/// Below is a short code example of a typical setup:
/// ```swift
/// @ValidationState var validation
///
/// var body: some View {
///     Form {
///         // all subviews that collect data ...
///
///         Button("Submit") {
///             guard validation.validateSubviews() else {
///                 return
///             }
///
///             // save data ...
///         }
///     }
///         .receiveValidation(in: $validation)
/// }
/// ```
///
/// - Note: `ValidationState` deeply integrates with [FocusState](https://developer.apple.com/documentation/SwiftUI/FocusState)
///     and supports to automatically
@propertyWrapper
public struct ValidationState: DynamicProperty {
    @State private var state = ValidationContext()

    public var wrappedValue: ValidationContext {
        state
    }

    public var projectedValue: ValidationState.Binding {
        Binding(binding: $state)
    }


    public init() {}
}


extension ValidationState {
    @propertyWrapper
    public struct Binding {
        private let binding: SwiftUI.Binding<ValidationContext>

        public var wrappedValue: ValidationContext {
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

        
        init(binding: SwiftUI.Binding<ValidationContext>) {
            self.binding = binding
        }
    }
}
