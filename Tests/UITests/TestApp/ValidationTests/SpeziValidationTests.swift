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


enum SpeziValidationTests: String, TestAppTests {
    case validation = "Validation"
    case focusedValidation = "FocusedValidation"

    @ViewBuilder
    var validation: some View {
        Text("Hello World")
    }

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .validation:
            ValidationTests()
        case .focusedValidation:
            FocusedValidationTests()
        }
    }
}


#Preview {
    TestAppTestsView<SpeziValidationTests>()
}
