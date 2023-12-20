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
                    .navigationBarTitleDisplayMode(.inline)
                    .viewStateAlert(state: $viewState)
                    .frame(maxWidth: .infinity, minHeight: proxy.size.height)
            }
        }
            .navigationBarBackButtonHidden(backButtonHidden)
    }

    @MainActor @ViewBuilder var form: some View {
        Text("Please enter your email address of your account. A email with an link to reset your password will be sent to the email address.")
            .multilineTextAlignment(.center)
        // TODO: top padding

        VerifiableTextField("E-Mail Address", text: $emailAddress)
            .validate(input: emailAddress, rules: .minimalEmail)
            .textFieldStyle(.roundedBorder)
            .autocorrectionDisabled(true)
            .textInputAutocapitalization(.never)
            .textContentType(.username)
            .keyboardType(.emailAddress)
            .font(.title3)

        Spacer()

        AsyncButton(state: $viewState) {
            Task {
                try await Task.sleep(for: .seconds(10))
                backButtonHidden = false
            }
            // TODO: some useful localized error!
            throw CancellationError()
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
