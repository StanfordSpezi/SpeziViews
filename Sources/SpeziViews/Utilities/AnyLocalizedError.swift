//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// A type erased version of `LocalizedError` with convenience initializers to do a best-effort transform an existing `Error` to an `LocalizedError`.
public struct AnyLocalizedError: LocalizedError {
    private static let globalDefaultErrorDescription = LocalizedStringResource("DEFAULT_ERROR_DESCRIPTION", bundle: .atURL(Bundle.module.bundleURL))

    /// A localized message describing what error occurred.
    public var errorDescription: String?
    /// A localized message describing the reason for the failure.
    public var failureReason: String?
    /// A localized message describing how one might recover from the failure.
    public var helpAnchor: String?
    /// A localized message providing "help" text if the user requests help.
    public var recoverySuggestion: String?


    /// Provides a best-effort approach to create a type erased version of `LocalizedError`.
    ///
    /// - Note: Refer to the documentation of the ``SwiftUICore/EnvironmentValues/defaultErrorDescription`` environment key on how to pass a useful and
    /// environment-defined default error description.
    ///
    /// - Parameters:
    ///   - error: The error instance that should be wrapped.
    ///   - defaultErrorDescription: The localized default error description that should be used if the `error` does not provide any context to create an error description.
    public init(error: any Error, defaultErrorDescription: @autoclosure () -> LocalizedStringResource? = nil) {
        self.init(error: error, defaultErrorDescription: {
            if let desc = defaultErrorDescription().map({ String(localized: $0) }) {
                return desc
            }
            #if DEBUG || TEST
            return "\(error)"
            #endif
            return String(localized: Self.globalDefaultErrorDescription)
        }())
    }
    
    /// Provides a best-effort approach to create a type erased version of `LocalizedError`.
    ///
    /// - Note: Refer to the documentation of the ``SwiftUICore/EnvironmentValues/defaultErrorDescription`` environment key on how to pass a useful and
    /// environment-defined default error description.
    ///
    /// - Parameters:
    ///   - error: The error instance that should be wrapped.
    ///   - defaultErrorDescription: The localized default error description that should be used if the `error` does not provide any context to create an error description.
    public init(error: any Error, defaultErrorDescription: @autoclosure () -> String) {
        switch error {
        case let error as any LocalizedError:
            self.errorDescription = error.errorDescription ?? defaultErrorDescription()
            self.failureReason = error.failureReason
            self.helpAnchor = error.helpAnchor
            self.recoverySuggestion = error.recoverySuggestion
        case let stringConvertible as any CustomStringConvertible:
            self.errorDescription = stringConvertible.description
        #if DEBUG || TEST
        case let debugStringConvertible as any CustomDebugStringConvertible:
            self.errorDescription = debugStringConvertible.debugDescription
        #endif
        default:
            self.errorDescription = defaultErrorDescription()
        }
    }
}
