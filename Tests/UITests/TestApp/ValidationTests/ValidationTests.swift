//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct ValidationTests: View {
    @ValidationState var validation
    @State var input: String = ""

    var body: some View {
        Form {
            Section {
                ValidationControls(validation: $validation)
            }

            VerifiableTextField("Input", text: $input)
                .validate(input: input, rules: [.minimalPassword])
        }
            .receiveValidation(in: $validation)
    }
}

#Preview {
    ValidationTests()
}
