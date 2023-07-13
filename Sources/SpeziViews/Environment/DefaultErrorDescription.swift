//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

/// An `EnvironmentKey` that provides access to the default, localized error description.
///
/// This might be helpful for views that rely on ``AnyLocalizedError``. Outer views can define a
/// sensible default for a localized default error description in the case that a sub-view has to display
/// an ``AnyLocalizedError`` for a generic error.
public struct DefaultErrorDescription: EnvironmentKey {
    public static let defaultValue: LocalizedStringResource? = nil
}

extension EnvironmentValues {
    /// Refer to the documentation of ``DefaultErrorDescription``.
    public var defaultErrorDescription: LocalizedStringResource? {
        get {
            self[DefaultErrorDescription.self]
        }
        set {
            self[DefaultErrorDescription.self] = newValue
        }
    }
}
