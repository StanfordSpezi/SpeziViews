//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


enum CustomError: Error, LocalizedError {
    case error

    var errorDescription: String? {
        "Custom Error"
    }

    var failureReason: String? {
        "Error was thrown!"
    }
}


struct AsyncButtonTestView: View {
    @State private var showCompleted = false
    @State private var viewState: ViewState = .idle

    var body: some View {
        List {
            if showCompleted {
                Section {
                    Text("Action executed")
                    Button("Reset") {
                        showCompleted = false
                    }
                }
            }
            Group {
                AsyncButton("Hello World") {
                    try? await Task.sleep(for: .milliseconds(500))
                    showCompleted = true
                }

                AsyncButton("Hello Throwing World", role: .destructive, state: $viewState) {
                    try? await Task.sleep(for: .milliseconds(500))
                    throw CustomError.error
                }
            }
                .disabled(showCompleted)
                .viewStateAlert(state: $viewState)
        }
    }
}


#if DEBUG
struct AsyncButtonTestView_Previews: PreviewProvider {
    static var previews: some View {
        AsyncButtonTestView()
    }
}
#endif
