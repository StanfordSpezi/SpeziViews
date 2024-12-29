//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Property wrapper to retrieve validation state of subviews.
///
/// The `ValidationState` property wrapper can be used to retrieve the validation state of
/// subviews and manually initiate validation (e.g., when pressing the submit button of a form).
/// To do so, you would typically call ``ValidationContext/validateSubviews(switchFocus:)`` within the `Button`
/// action. This call can be used to automatically switch focus to the first field that failed validation.
///
/// The `ValidationState` property wrapper works in conjunction with the ``SwiftUICore/View/receiveValidation(in:)`` modifier
/// to receive validation state from the child views.
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
/// ## Topics
///
/// ### Inspecting Validation State
/// - ``ValidationContext``
/// - ``CapturedValidationState``
/// - ``ValidationEngine``
@propertyWrapper
public struct ValidationState: DynamicProperty {
    @State private var state = ValidationContext()

    /// Access the captured validation context.
    public var wrappedValue: ValidationContext {
        state
    }

    /// Creates a binding that you can pass around.
    public var projectedValue: ValidationState.Binding {
        Binding(binding: $state)
    }


    public init() {}
}


extension ValidationState {
    /// A binding to a ``ValidationState``.
    @propertyWrapper
    public struct Binding: Sendable {
        private let binding: SwiftUI.Binding<ValidationContext>

        /// The validation context.
        public var wrappedValue: ValidationContext {
            get {
                binding.wrappedValue
            }
            nonmutating set {
                binding.wrappedValue = newValue
            }
        }

        /// Creates a binding.
        public var projectedValue: Binding {
            self
        }

        
        init(binding: SwiftUI.Binding<ValidationContext>) {
            self.binding = binding
        }
    }
}
