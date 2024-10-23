//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


/// Allows SwiftUI views to track their state and communicate with other views.
///
/// A `ViewState` provides a built-in mechanism for tracking the state of a Spezi UI component.
/// A view can be in one of three states: `idle`, `processing`, or `error`.
///
/// The ``SwiftUICore/View/viewStateAlert(state:)-4wzs4`` view modifier can be used to automatically notify users with an
/// [`Alert`](https://developer.apple.com/documentation/swiftui/view/alert(_:ispresented:actions:)-3npin) when the
/// `ViewState` transitions into an error state.
///
/// This is why the `error` state takes a
/// [`LocalizedError`](https://developer.apple.com/documentation/foundation/localizederror) as an associated value:
/// it provides a localized error description for the alert that is presented to users.
///
/// > Tip:
/// > Use ``AnyLocalizedError`` to handle both localized and non-localized errors simultaneously. Non-localized
/// > errors are handled on a best-effort basis, meaning a description may not always be available.
///
/// ```swift
/// import SpeziViews
/// import SwiftUI
///
/// struct ViewStateExample: View {
///     @State private var viewState: ViewState = .idle
///
///     var body: some View {
///         VStack {
///             Button("Action") {
///                 viewState = .processing
///                 do {
///                     // Call an asynchronous function that may throw an error...
///                     viewState = .idle
///                 } catch {
///                     viewState = .error(AnyLocalizedError(error: error))
///                 }
///             }
///             .viewStateAlert(state: $viewState)
///         }
///     }
/// }
/// ```
///
/// > Tip:
/// > To handle more complex view states, you can use the ``OperationState`` protocol to map a more sophisticated state machine to `ViewState` instances, as defined
/// > by the ``OperationState/representation`` property. This allows you to benefit from the same built-in behavior and modifiers that `ViewState` provides.
/// > For instructions on defining such a mapping, refer to the ``OperationState`` documentation.
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
