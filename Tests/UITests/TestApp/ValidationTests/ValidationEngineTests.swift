//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct ValidationEngineTests: View {
    @State var input: String = ""

    @State var lastValid: Bool?
    @State var engines: [ValidationContext] = [] // TODO: provide extension to array!

    var body: some View {
        Form {
            Section {
                Text("Has Engines: \(!engines.isEmpty ? "Yes" : "No")")
                if let lastValid {
                    Text("Last state: \(lastValid ? "valid": "invalid")")
                }
                Button("Validate", action: {
                    lastValid = engines.validateSubviews()
                    // validating without direct access to the input value
                    // TODO execute!
                })
            }

            VerifiableTextField("Input", text: $input)
                .validate(input: input, rules: [.minimalPassword])
                .receiveValidationEngines { engines in
                    self.engines = engines
                    print("Received engines \(engines)")
                }
        }
    }
}

#Preview {
    ValidationEngineTests()
}
