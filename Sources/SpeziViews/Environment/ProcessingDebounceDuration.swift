//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// An `EnvironmentKey` that provides a generalized configuration for debounce durations for any processing-related operations.
///
/// This might be helpful to provide extensive customization points without introducing clutter in the initializer of views.
/// The ``AsyncButton`` is one example where this `EnvironmentKey` is used.
struct ProcessingDebounceDuration: EnvironmentKey {
    static let defaultValue: Duration = .milliseconds(150)
}


extension EnvironmentValues {
    /// A `Duration` that provides a generalized configuration for debounce durations for any processing-related operations.
    ///
    /// This might be helpful to provide extensive customization points without introducing clutter in the initializer of views.
    /// The ``AsyncButton`` is one example where this `EnvironmentKey` is used.
    ///
    /// - Note: The default value is `150ms`.
    public var processingDebounceDuration: Duration {
        get {
            self[ProcessingDebounceDuration.self]
        }
        set {
            self[ProcessingDebounceDuration.self] = newValue
        }
    }
}
