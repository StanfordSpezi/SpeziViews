//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct NameFieldsTestView: View {
    @State var name = PersonNameComponents()

    @FocusState var focus: String?
    
    var body: some View {
        VStack {
            NameFields(
                name: $name,
                givenNameField: FieldLocalizationResource(title: "First Title", placeholder: "First Placeholder"),
                familyNameField: FieldLocalizationResource(title: "Second Title", placeholder: "Second Placeholder")
            )
                .padding(32)
            Form {
                NameFields(name: $name, givenNameFieldIdentifier: "givenName", familyNameFieldIdentifier: "familyName", focusedState: $focus)
            }
        }
            .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
struct NameFieldsTestView_Previews: PreviewProvider {
    static var previews: some View {
        NameFieldsTestView()
    }
}
#endif
