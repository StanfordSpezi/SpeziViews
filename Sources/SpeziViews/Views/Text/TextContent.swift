//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

/// The `TextContent` enum represents either a plain string or a localized string resource.
///
/// Use this enum to encapsulate text content in your application, allowing flexibility in handling localized and non-localized strings.
///
/// ```swift
/// // Example usage:
/// let content: TextContent = .localized(LocalizedStringResource("HELLO_SPEZI", bundle: .main))
/// let localizedString = content.localizedString(for: .current)
/// print(localizedString) // Prints the localized string for the current locale.
/// ```
enum TextContent {
    case string(_ value: String)
    case localized(_ value: LocalizedStringResource)

    /// Returns the localized string representation of the content for a given locale.
    ///
    /// - Parameter locale: The locale for which to retrieve the localized string.
    /// - Returns: The localized string corresponding to the content.
    func localizedString(for locale: Locale) -> String {
        switch self {
        case let .string(string):
            return string
        case let .localized(resource):
            return resource.localizedString(for: locale)
        }
    }
}
