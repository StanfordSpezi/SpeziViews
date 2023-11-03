//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI

enum Field: Hashable {
    case input
    case nonEmptyInput
}


struct FocusedValidationTests: View {
    @State var input: String = ""
    @State var nonEmptyInput: String = ""

    @FocusState var focus: Field?
    @ValidationState(Field.self) var validation

    var body: some View {
        Form {
            Section {
                ValidationControls(validation: $validation)
            }

            VerifiableTextField("Input", text: $input)
                .focused($focus, equals: .input)
                .validate(input: input, field: Field.input, rules: .minimalPassword)

            VerifiableTextField("Non-Empty Input", text: $nonEmptyInput)
                .focused($focus, equals: .nonEmptyInput)
                .validate(input: nonEmptyInput, field: Field.nonEmptyInput, rules: .nonEmpty)
        }
            .receiveValidation(in: $validation, focus: $focus)
    }
}

#Preview {
    FocusedValidationTests()
}
