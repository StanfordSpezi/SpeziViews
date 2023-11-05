//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A failed validation result of a ``ValidationRule`` for a particular input.
///
/// For more information see ``ValidationRule/validate(_:)``.
public struct FailedValidationResult: Identifiable, Equatable, CustomLocalizedStringResourceConvertible {
    /// The identifier of the ``ValidationRule`` that produced this result.
    public var id: ValidationRule.ID
    /// A recovery suggestion for the validated input.
    public let message: LocalizedStringResource

    public var localizedStringResource: LocalizedStringResource {
        message
    }

    init(from rule: ValidationRule) {
        self.id = rule.id
        self.message = rule.message
    }
}
