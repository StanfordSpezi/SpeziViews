//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

@testable import SpeziViews
import SwiftUI
import Testing


@Suite("ManagedNavigationStackIdentifierTests")
struct ManagedNavigationStackIdentifierTests {
    @Test("OnboardingIdentifier ViewModifier")
    @MainActor
    func testOnboardingIdentifierModifier() throws {
        let stack = ManagedNavigationStack {
            Text("Hello World")
                .navigationStepIdentifier("Custom Identifier")
        }
        
        let identifier = #require(stack.path.firstStepIdentifier)
        #expect(identifier.identifierKind == .identifiable("Custom Identifier"))
    }
}
