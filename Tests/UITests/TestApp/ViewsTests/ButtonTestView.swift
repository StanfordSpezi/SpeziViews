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


struct StateAsyncButton: View {
    private let text: String

    @State private var presentedText: String?

    var body: some View {
        Section {
            AsyncButton("State Captured") {
                presentedText = text
            }
        } footer: {
            if let presentedText {
                Text("Captured \(presentedText)")
            }
        }
    }


    init(text: String) {
        self.text = text
    }
}


struct ButtonTestView: View {
    @State private var showCompleted = false
    @State private var viewState: ViewState = .idle

    @State private var showInfo = false
    @State private var presentedText = "Hello"

    var body: some View {
        List { // swiftlint:disable:this closure_body_length
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
                    try await Task.sleep(for: .milliseconds(500))
                    throw CustomError.error
                }
                    .asyncButtonProcessingStyle(.listRow)
            }
                .disabled(showCompleted)
                .viewStateAlert(state: $viewState)

            StateAsyncButton(text: presentedText)

            Section {
                HStack {
                    Button {
                        viewState = .error(CustomError.error)
                    } label: {
                        Text("Entity")
                            .foregroundStyle(.primary)
                    }
                    Spacer()
                    InfoButton("Entity Info") {
                        showCompleted = true
                    }
                }
            }
        }
            .task {
                try? await Task.sleep(for: .milliseconds(500))
                presentedText = "Hello World"
            }
    }
}


#if DEBUG
struct AsyncButtonTestView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonTestView()
    }
}
#endif
