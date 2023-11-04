//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension ValidationEngine {
    /// The configuration of a ``ValidationEngine``.
    public struct Configuration: OptionSet, EnvironmentKey, Equatable {
        /// This configuration controls the behavior of the ``ValidationEngine/displayedValidationResults`` property.
        ///
        /// If ``ValidationEngine/submit(input:debounce:)`` is called with empty input and this option is set, then the
        ///  ``ValidationEngine/displayedValidationResults`` will display no failed validations. However,
        ///  ``ValidationEngine/displayedValidationResults`` will still display all validations if validation is done through a manual call to ``ValidationEngine/runValidation(input:)``.
        public static let hideFailedValidationOnEmptySubmit = Configuration(rawValue: 1 << 0)

        /// This configuration controls the behavior of the ``ValidationEngine/inputValid`` property.
        ///
        /// If this configuration is set, the Validation Engine will treat no input (a validation engine
        /// that was never run) as being valid. Otherwise, invalid.
        public static let considerNoInputAsValid = Configuration(rawValue: 1 << 1)

        /// Default value without any configuration options.
        public static let defaultValue: Configuration = []


        public let rawValue: UInt


        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
    }
}


extension EnvironmentValues {
    /// Access the ``ValidationEngine/Configuration-swift.struct`` from the environment.
    public var validationConfiguration: ValidationEngine.Configuration {
        get {
            self[ValidationEngine.Configuration.self]
        }
        set {
            self[ValidationEngine.Configuration.self].formUnion(newValue)
        }
    }
}
