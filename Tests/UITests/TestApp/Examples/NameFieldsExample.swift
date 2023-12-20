//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


struct NameFieldsExample: View {
    @State var name = PersonNameComponents()
    @State var hideBackButton = true

    var body: some View {
        Form {
            Section("Name") {
                Grid(horizontalSpacing: 15) {
                    NameFieldRow("First", name: $name, for: \.givenName) {
                        Text(verbatim: "enter your first name")
                    }

                    Divider()
                        .gridCellUnsizedAxes(.horizontal)

                    NameFieldRow("Middle", name: $name, for: \.middleName) {
                        Text(verbatim: "enter your middle name")
                    }

                    Divider()
                        .gridCellUnsizedAxes(.horizontal)

                    NameFieldRow("Last", name: $name, for: \.familyName) {
                        Text(verbatim: "enter your last name")
                    }
                }
            }
        }
            .navigationTitle("Enter your details")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(hideBackButton)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        hideBackButton = false
                    }
                }
            }
    }
}


#if DEBUG
#Preview {
    NavigationStack {
        NameFieldsExample()
    }
}
#endif
