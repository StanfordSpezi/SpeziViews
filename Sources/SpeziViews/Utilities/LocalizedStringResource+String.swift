//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension LocalizedStringResource {
    /// Creates a localized `String` from the given `LocalizedStringResource`.
    /// - Parameter locale: Specifies an override locale.
    /// - Returns: The localized string.
    public func localizedString(for locale: Locale? = nil) -> String {
        if let locale {
            var resource = self
            resource.locale = locale
            return String(localized: resource)
        }

        return String(localized: self)
    }
}
