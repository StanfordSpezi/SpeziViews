//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziValidation
import SwiftUI


struct ValidationPredicateTests: View {
    enum Selection: String, CaseIterable, Hashable {
        case none = "Nothing selected"
        case accept = "Accept"
        case deny = "Deny"
    }

    @State private var selection: Selection = .none
    @ValidationState private var validationState

    var body: some View {
        List {
            VStack(alignment: .leading) {
                Picker(selection: $selection) {
                    ForEach(Selection.allCases, id: \.rawValue) { selection in
                        Text(selection.rawValue)
                            .tag(selection)
                    }
                } label: {
                    Text("Cookies")
                }
                ValidationResultsView(results: validationState.allDisplayedValidationResults)
            }
                .validate(selection != .none, message: "This field must be selected.")
                .receiveValidation(in: $validationState)
        }
    }
}
