//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct OperationStateTestView: View {
    enum OperationStateTest: OperationState {
        case ready
        case someOperationStep
        case error(LocalizedError)
        
        
        var representation: ViewState {
            switch self {
            case .ready:
                .idle
            case .someOperationStep:
                .processing
            case .error(let localizedError):
                .error(localizedError)
            }
        }
    }
    
    struct TestError: LocalizedError {
        var errorDescription: String?
        var failureReason: String?
        var helpAnchor: String?
        var recoverySuggestion: String?
    }

    let testError = TestError(
        errorDescription: nil,
        failureReason: "Failure Reason",
        helpAnchor: "Help Anchor",
        recoverySuggestion: "Recovery Suggestion"
    )
    
    @State var operationState: OperationStateTest = .ready
    
    var body: some View {
        VStack {
            Text("Operation State: \(String(describing: operationState))")
                .accessibilityIdentifier("operationState")
        }
            .task {
                operationState = .someOperationStep
                try? await Task.sleep(for: .seconds(4))
                operationState = .error(
                    AnyLocalizedError(
                        error: testError,
                        defaultErrorDescription: "Error Description"
                    )
                )
            }
            .viewStateAlert(state: operationState)
    }
}


#Preview {
    OperationStateTestView()
}
