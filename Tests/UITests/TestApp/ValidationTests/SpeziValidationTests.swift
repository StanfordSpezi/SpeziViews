//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI
import XCTestApp


enum SpeziValidationTests: String, TestAppTests {
    case validation = "Validation"
    case validationRules = "ValidationRules"
    case validationPredicate = "Validation Picker"

    func view(withNavigationPath path: Binding<NavigationPath>) -> some View {
        switch self {
        case .validation:
            FocusedValidationTests()
        case .validationRules:
            DefaultValidationRules()
        case .validationPredicate:
            ValidationPredicateTests()
        }
    }
}


#Preview {
    TestAppTestsView<SpeziValidationTests>()
}
