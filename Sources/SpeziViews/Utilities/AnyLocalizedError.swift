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
    public init(error: any Error, defaultErrorDescription: LocalizedStringResource? = nil) {
        self.init(error: error, defaultErrorDescription: String(localized: defaultErrorDescription ?? Self.globalDefaultErrorDescription))
    }
    
    /// Provides a best-effort approach to create a type erased version of `LocalizedError`.
    ///
    /// - Note: Refer to the documentation of the ``SwiftUICore/EnvironmentValues/defaultErrorDescription`` environment key on how to pass a useful and
    /// environment-defined default error description.
    ///
    /// - Parameters:
    ///   - error: The error instance that should be wrapped.
    ///   - defaultErrorDescription: The localized default error description that should be used if the `error` does not provide any context to create an error description.
    public init(error: any Error, defaultErrorDescription: String) {
        switch error {
        case let localizedError as LocalizedError:
            errorDescription = localizedError.errorDescription ?? defaultErrorDescription
            failureReason = localizedError.failureReason
            helpAnchor = localizedError.helpAnchor
            recoverySuggestion = localizedError.recoverySuggestion
        case let error where type(of: error) is NSError.Type:
            let error = error as NSError
            errorDescription = error.localizedDescription
            failureReason = error.localizedFailureReason
            helpAnchor = error.helpAnchor
            recoverySuggestion = error.localizedRecoverySuggestion
        case let customStringConvertible as CustomStringConvertible:
            errorDescription = customStringConvertible.description
        default:
            errorDescription = defaultErrorDescription
        }
    }
}

/// Determines whether an exietential `Error` is an `NSError` instance.
///
/// This function exists because all Swift `Error`s can implicitly be bridged to `NSError`,
/// meaning that checks like `error is NSError` or `error as? NSError` will always succeed.
@inlinable
func isNSError(_ error: any Error) -> Bool {
    type(of: error) is NSError.Type
}
