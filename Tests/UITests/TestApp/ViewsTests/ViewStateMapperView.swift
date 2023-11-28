//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ViewStateMapperTestView: View {
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
    @State var viewState: ViewState = .idle

    
    var body: some View {
        VStack {
            Text("View State: \(String(describing: viewState))")
                .padding(.bottom, 12)
            
            Text("Operation State: \(String(describing: operationState))")
                .accessibilityIdentifier("operationState")
        }
            .task {
                operationState = .someOperationStep
                try? await Task.sleep(for: .seconds(10))
                operationState = .error(
                    AnyLocalizedError(
                        error: testError,
                        defaultErrorDescription: "Error Description"
                    )
                )
            }
            .map(state: operationState, to: $viewState)
            .viewStateAlert(state: $viewState)
    }
}


#Preview {
    ViewStateMapperTestView()
}
