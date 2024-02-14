//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct ValidationExample: View {
    @State var email: String = ""
    @State var password: String = ""

    @State var content: String = ""

    @State var backButtonHidden = true

    @ValidationState var validation

    var body: some View {
        Form {
            Section("Credentials") {
                VerifiableTextField("Email", text: $email)
                    .validate(input: email, rules: .minimalEmail)

                VerifiableTextField("Password", text: $password, type: .secure)
                    .validate(input: password, rules: .minimalPassword)
            }
                #if !os(macOS)
                .textInputAutocapitalization(.never)
                #endif
                .autocorrectionDisabled(true)

            Section {
                VerifiableTextField("Username", text: $content)
                    .validate(input: content, rules: .nonEmpty)
            } footer: {
                Text("Your username is displayed to other users.")
            }
        }
            .navigationTitle("Signup")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationBarBackButtonHidden(backButtonHidden)
            .receiveValidation(in: $validation)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        backButtonHidden = false
                    }
                        .disabled(!validation.allInputValid)
                }
            }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        ValidationExample()
    }
}
#endif
