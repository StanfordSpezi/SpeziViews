//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A ``FieldLocalizationResource`` describes a localization of a `TextField` instance using a ``FieldLocalizationResource/title`` and ``FieldLocalizationResource/placeholder``.
public struct FieldLocalizationResource: Codable {
    /// The localized title of a `TextField`.
    public let title: LocalizedStringResource
    /// The localized placeholder of a `TextField`.
    public let placeholder: LocalizedStringResource


    /// Creates a new ``FieldLocalizationResource`` instance.
    /// - Parameters:
    ///   - title: The localized title of a `TextField`.
    ///   - placeholder: The localized placeholder of a `TextField`.
    public init(title: LocalizedStringResource, placeholder: LocalizedStringResource) {
        self.title = title
        self.placeholder = placeholder
    }
    
    /// Creates a new ``FieldLocalizationResource`` instance.
    /// - Parameters:
    ///   - title: The title of a `TextField` following the localization mechanisms lined out in `StringProtocol.localized()`.
    ///   - placeholder: The placeholder of a `TextField` following the localization mechanisms lined out in `StringProtocol.localized()`.
    ///   - bundle: The `Bundle` used for localization. If you have differing bundles for title and placeholder use the
    ///     alternative initializer ``init(title:placeholder:)``.
    @_disfavoredOverload
    public init<Title: StringProtocol, Placeholder: StringProtocol>(
        title: Title,
        placeholder: Placeholder,
        bundle: Bundle? = nil
    ) {
        self.init(title: title.localized(bundle), placeholder: placeholder.localized(bundle))
    }
}
