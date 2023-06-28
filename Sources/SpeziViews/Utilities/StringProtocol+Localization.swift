//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension StringProtocol {
    /// Creates a localized version of the instance conforming to `StringProtocol`.
    ///
    /// String literals (`StringLiteralType`) and `String.LocalizationValue` instances are tried to be localized using the main bundle.
    /// `String` instances are not localized. You have to manually localize a `String` instance using `String(localized:)`.
    @available(*, deprecated, message: "The `localized` property has been renamed to the `localized()` to better communicate its manipulations.")
    public var localized: LocalizedStringResource {
        localized(nil)
    }
    
    
    /// Creates a localized version of the instance conforming to `StringProtocol`.
    ///
    /// String literals (`StringLiteralType`) and `String.LocalizationValue` instances are tried to be localized using the provided bundle.
    /// `String` instances are not localized. You have to manually localize a `String` instance using `String(localized:)`.
    public func localized(_ bundle: Bundle? = nil) -> LocalizedStringResource {
        let bundleDescription = bundle.map { LocalizedStringResource.BundleDescription.atURL(from: $0) } ?? .main

        switch self {
        case let text as String.LocalizationValue:
            return LocalizedStringResource(text, bundle: bundleDescription)
        case let text as StringLiteralType:
            return LocalizedStringResource(String.LocalizationValue(text), bundle: bundleDescription)
        default:
            return LocalizedStringResource(stringLiteral: String(self))
        }
    }
}
