//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI

enum Field: String, Hashable {
    case input = "Input"
    case nonEmptyInput = "Non-Empty Input"
}


struct FocusedValidationTests: View {
    // CHILD VIEW CONTENT
    @State var input: String = ""
    @State var nonEmptyInput: String = ""

    // PARENT VIEW CONTENT
    @ValidationState var validation

    @State var lastValid: Bool? // swiftlint:disable:this discouraged_optional_boolean
    @State var switchFocus = true
    @FocusState var focus: Field?

    var body: some View {
        Form {
            Section {
                Text("Has Engines: \(!validation.isEmpty ? "Yes" : "No")")
                Text("Input Valid: \(validation.allInputValid ? "Yes" : "No")")
                if let lastValid {
                    Text("Last state: \(lastValid ? "valid" : "invalid")")
                }
                Button("Validate", action: {
                    // validating without direct access to the input value
                    lastValid = validation.validateSubviews(switchFocus: switchFocus) // TODO test the focus switch?
                })
                Toggle("Switch Focus", isOn: $switchFocus)
            }

            VerifiableTextField("\(Field.input.rawValue)", text: $input)
                .focused($focus, equals: .input)
                .validate(input: input, rules: .minimalPassword)

            VerifiableTextField("\(Field.nonEmptyInput.rawValue)", text: $nonEmptyInput)
                .focused($focus, equals: .nonEmptyInput)
                .validate(input: nonEmptyInput, rules: .nonEmpty)
        }
            .receiveValidation(in: $validation)
    }
}

#Preview {
    FocusedValidationTests()
}
