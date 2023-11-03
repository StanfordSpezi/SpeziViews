//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct ValidationControls<FocusValue: Hashable>: View {
    @ValidationState.Binding var validation: ValidationContext<FocusValue>

    @State var lastValid: Bool? // swiftlint:disable:this discouraged_optional_boolean

    var body: some View {
        Text("Has Engines: \(!validation.isEmpty ? "Yes" : "No")")
        Text("Input Valid: \(validation.inputValid ? "Yes" : "No")")
        if let lastValid {
            Text("Last state: \(lastValid ? "valid" : "invalid")")
        }
        Button("Validate", action: {
            // validating without direct access to the input value
            lastValid = validation.validateSubviews()
        })
    }
}


#Preview {
    @ValidationState<Never> var state
    return ValidationControls<Never>(validation: $state)
}
