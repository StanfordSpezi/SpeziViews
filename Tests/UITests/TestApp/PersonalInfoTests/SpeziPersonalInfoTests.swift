//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziPersonalInfo
import SwiftUI
import XCTestApp


enum SpeziPersonalInfoTests: String, TestAppTests {
    case nameFields = "Name Fields"
    case userProfile = "User Profile"

    @ViewBuilder
    private var nameFields: some View {
        NameFieldsTestView()
    }

    @ViewBuilder
    private var userProfile: some View {
        UserProfileView(
            name: PersonNameComponents(givenName: "Paul", familyName: "Schmiedmayer")
        )
            .frame(width: 100)
        UserProfileView(
            name: PersonNameComponents(givenName: "Leland", familyName: "Stanford"),
            imageLoader: {
                try? await Task.sleep(for: .seconds(3))
                return Image(systemName: "person.crop.artframe")
            }
        )
            .frame(width: 200)
    }


    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .nameFields:
            nameFields
        case .userProfile:
            userProfile
        }
    }
}


#Preview {
    TestAppTestsView<SpeziPersonalInfoTests>()
}
