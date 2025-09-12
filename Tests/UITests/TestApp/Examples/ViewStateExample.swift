//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SpeziViews
import SwiftUI


struct CustomViewStateError: LocalizedError {
    var errorDescription: String? {
        "Failed Password Reset"
    }

    var failureReason: String? {
        "There was an issue sending out your password reset link. Please try again!"
    }

    init() {}
}


struct ViewStateExample: View {
    @State var emailAddress = ""
    @State var viewState: ViewState = .idle

    @State var backButtonHidden = true

    var body: some View {
        GeometryReader { proxy in
            ScrollView(.vertical) {
                VStack {
                    form
                        .padding()
                }
                    .navigationTitle("Reset Password")
                    #if !os(macOS) && !os(tvOS)
                    .navigationBarTitleDisplayMode(.inline)
                    #endif
                    .viewStateAlert(state: $viewState)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
            .navigationBarBackButtonHidden(backButtonHidden)
    }

    @MainActor @ViewBuilder var form: some View {
        Text("Please enter your email address of your account. A email with an link to reset your password will be sent to the email address.")
            .multilineTextAlignment(.center)

        VerifiableTextField("E-Mail Address", text: $emailAddress)
            .validate(input: emailAddress, rules: .minimalEmail)
            #if !os(tvOS)
            .textFieldStyle(.roundedBorder)
            #endif
            .autocorrectionDisabled(true)
            #if !os(macOS)
            .textInputAutocapitalization(.never)
            .keyboardType(.emailAddress)
            #endif
            .textContentType(.username)
            .font(.title3)

        Spacer()

        AsyncButton(state: $viewState) {
            Task {
                try await Task.sleep(for: .seconds(10))
                backButtonHidden = false
            }
            throw CustomViewStateError()
        } label: {
            Text("Reset Password")
                .padding(8)
                .frame(maxWidth: .infinity)
        }
            .buttonStyle(.borderedProminent)
            .padding(8)
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ViewStateExample()
    }
}
#endif
