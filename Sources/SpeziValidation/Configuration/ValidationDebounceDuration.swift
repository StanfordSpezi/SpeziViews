//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// The debounce duration for Validation Engine
struct ValidationDebounceDurationKey: EnvironmentKey {
    static let defaultValue: Duration = .seconds(0.5)
}


extension EnvironmentValues {
    /// The configurable debounce duration for input submission.
    ///
    /// Having a debounce like this, ensures that validation error messages don't get into the way when a user
    /// is actively typing into a text field.
    /// This duration is used to debounce repeated calls to ``ValidationEngine/submit(input:debounce:)`` where `debounce` is set to `true`.
    public var validationDebounce: Duration {
        get {
            self[ValidationDebounceDurationKey.self]
        }
        set {
            self[ValidationDebounceDurationKey.self] = newValue
        }
    }
}
