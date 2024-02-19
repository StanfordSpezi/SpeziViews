//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI


struct NameFieldsTestView: View {
    @State var name = PersonNameComponents()
    
    var body: some View {
        VStack {
            Form {
                nameFields
            }
        }
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }


    @ViewBuilder
    private var nameFields: some View {
        Grid {
            NameFieldRow("First Name", name: $name, for: \.givenName) {
                Text(verbatim: "enter your first name")
            }

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow("Last Name", name: $name, for: \.familyName) {
                Text(verbatim: "enter your last name")
            }
        }
    }
}


#if DEBUG
struct NameFieldsTestView_Previews: PreviewProvider {
    static var previews: some View {
        NameFieldsTestView()
    }
}
#endif
