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
    case validationRules = "ValidationRules"

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .validation:
            FocusedValidationTests()
        case .validationRules:
            DefaultValidationRules()
        }
    }
}


#Preview {
    TestAppTestsView<SpeziValidationTests>()
}
