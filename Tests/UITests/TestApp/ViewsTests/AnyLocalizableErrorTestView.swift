//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct AnyLocalizableErrorTestView: View {
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            Section("Trigger Error") {
                Button("Swift Error (Simple)") {
                    `throw`(SimpleSwiftError(message: "Simple Swift Error Message"))
                }
                Button("Swift Error (Localized)") {
                    `throw`(LocalizedSwiftError(
                        errorDescription: "Localized Swift Error Desc",
                        failureReason: "Localized Swift Failure Reason",
                        helpAnchor: "Localized Swift Help Anchor",
                        recoverySuggestion: "Localized Swift Recovery Suggestion"
                    ))
                }
                Button("NSError (Simple 1)") {
                    `throw`(NSError(domain: "edu.stanford.SpeziViews", code: 123))
                }
                Button("NSError (Simple 2)") {
                    `throw`(NSError(domain: "edu.stanford.SpeziViews", code: 123, userInfo: [
                        NSLocalizedDescriptionKey: "NSError Localized Description Text"
                    ]))
                }
                Button("NSError (Simple 3)") {
                    `throw`(NSError(domain: "edu.stanford.SpeziViews", code: 123, userInfo: [
                        NSLocalizedDescriptionKey: "NSError Localized Description Text",
                        NSLocalizedFailureReasonErrorKey: "NSError Localized Failure Reason Text",
                        NSHelpAnchorErrorKey: "NSError Localized Help Anchor Text",
                        NSLocalizedRecoverySuggestionErrorKey: "NSError Localized Recovery Suggestion Text"
                    ]))
                }
            }
        }
        .viewStateAlert(state: $viewState)
    }
    
    private func `throw`(_ error: some Error) {
        viewState = .error(AnyLocalizedError(error: error))
    }
}


extension AnyLocalizableErrorTestView {
    fileprivate struct SimpleSwiftError: Error {
        let message: String
    }
    
    fileprivate struct LocalizedSwiftError: Error, LocalizedError {
        var errorDescription: String?
        var failureReason: String?
        var helpAnchor: String?
        var recoverySuggestion: String?
    }
}
