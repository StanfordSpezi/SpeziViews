//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Allows SwiftUI views to keep track of their state and communicate to outside views.
public enum ViewState {
    /// The view is idle and displaying content.
    case idle
    /// The view is in a processing state, e.g. loading content.
    case processing
    /// The view is in an error state, e.g., loading the content failed.
    case error(LocalizedError)
}


// MARK: - ViewState Extensions
extension ViewState: Equatable {
    public static func == (lhs: ViewState, rhs: ViewState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.processing, .processing), (.error, .error):
            return true
        default:
            return false
        }
    }
}


// MARK: - ViewState + Error
extension ViewState {
    /// The localized error title of the view if it is in an error state. An empty string if it is in an non-error state.
    public var errorTitle: String {
        switch self {
        case let .error(error):
            guard let errorTitle = error.errorDescription else {
                fallthrough
            }

            guard errorTitle != errorDescription else {
                // in the case that an error only has a `errorDescription` we don't use it as the title but use a generic default.
                fallthrough
            }

            return errorTitle
        default:
            return String(localized: "Error", bundle: .module, comment: "View State default error title")
        }
    }

    /// The localized error description of the view if it is in an error state. An empty string if it is in an non-error state.
    public var errorDescription: String {
        switch self {
        case let .error(error):
            var errorDescription = ""
            if let failureReason = error.failureReason {
                errorDescription.append("\(failureReason)")
            }
            if let helpAnchor = error.helpAnchor {
                errorDescription.append("\(errorDescription.isEmpty ? "" : "\n\n")\(helpAnchor)")
            }
            if let recoverySuggestion = error.recoverySuggestion {
                errorDescription.append("\(errorDescription.isEmpty ? "" : "\n\n")\(recoverySuggestion)")
            }
            if errorDescription.isEmpty {
                errorDescription = error.localizedDescription
            }
            return errorDescription
        default:
            return ""
        }
    }
}
