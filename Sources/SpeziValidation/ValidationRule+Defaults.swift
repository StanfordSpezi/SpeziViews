//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import Foundation


extension ValidationRule {
    /// A `ValidationRule` that checks that the supplied content is non-empty (`\S+`).
    ///
    /// The definition of **non-empty** in this context refers to: a string that is not the empty string and
    /// does also not just contain whitespace-only characters.
    public static let nonEmpty: ValidationRule = {
        guard let regex = try? Regex(#".*\S+.*"#) else {
            fatalError("Failed to build the nonEmpty validation rule!")
        }

        return ValidationRule(regex: regex, message: "VALIDATION_RULE_NON_EMPTY", bundle: .module)
    }()

    /// A `ValidationRule` that checks that the supplied content only contains unicode letters.
    ///
    /// - See: `Character/isLetter`.
    public static let unicodeLettersOnly: ValidationRule = {
        ValidationRule(rule: { $0.allSatisfy { $0.isLetter } }, message: "VALIDATION_RULE_UNICODE_LETTERS", bundle: .module)
    }()

    /// A `ValidationRule` that checks that the supplied contain only contains ASCII letters.
    ///
    /// - Note: It is recommended to use ``unicodeLettersOnly`` in production environments.
    /// - See: `Character/isASCII`.
    public static let asciiLettersOnly: ValidationRule = {
        ValidationRule(rule: { $0.allSatisfy { $0.isASCII } }, message: "VALIDATION_RULE_UNICODE_LETTERS_ASCII", bundle: .module)
    }()

    /// A `ValidationRule` that imposes minimal constraints on a E-Mail input.
    ///
    /// This ValidationRule matches with any strings that contain at least one `@` symbol followed by at least one
    /// character (`.*@.+`). Use this in environments where you verify the existence and ownership of the E-Mail
    /// address (e.g., by sending a verification link to the address).
    ///
    /// - See: A more detailed discussion about validation E-Mail inout can be found [here](https://stackoverflow.com/a/48170419).
    public static let minimalEmail: ValidationRule = {
        guard let regex = try? Regex(".*@.+") else {
            fatalError("Failed to build the minimalEmail validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_MINIMAL_EMAIL",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 8 characters for minimal password complexity.
    ///
    /// See ``ValidationRule`` for a discussion and recommendation on password complexity rules.
    public static let minimalPassword: ValidationRule = {
        guard let regex = try? Regex(#".{8,}"#) else {
            fatalError("Failed to build the minimalPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_PASSWORD_LENGTH \(8)",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 10 characters for improved password complexity.
    ///
    /// See ``ValidationRule`` for a discussion and recommendation on password complexity rules.
    public static let mediumPassword: ValidationRule = {
        guard let regex = try? Regex(#".{10,}"#) else {
            fatalError("Failed to build the mediumPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_PASSWORD_LENGTH \(10)",
            bundle: .module
        )
    }()

    /// A `ValidationRule` that requires a password of at least 10 characters for extended password complexity.
    ///
    /// See ``ValidationRule`` for a discussion and recommendation on password complexity rules.
    public static let strongPassword: ValidationRule = {
        guard let regex = try? Regex(#".{12,}"#) else {
            fatalError("Failed to build the strongPassword validation rule!")
        }

        return ValidationRule(
            regex: regex,
            message: "VALIDATION_RULE_PASSWORD_LENGTH \(12)",
            bundle: .module
        )
    }()
}
