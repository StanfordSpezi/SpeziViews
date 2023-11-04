//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI

struct DefaultValidationRules: View {
    @State var input: String = ""
    var body: some View {
        VerifiableTextField("Field", text: $input)
            .validate(input: input, rules: [
                .nonEmpty,
                .unicodeLettersOnly,
                .asciiLettersOnly,
                .minimalEmail,
                .minimalPassword,
                .mediumPassword,
                .strongPassword
            ])
    }
}

#Preview {
    DefaultValidationRules()
}
