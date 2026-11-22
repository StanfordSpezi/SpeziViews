//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


private struct PlainStep: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    let title: LocalizedStringResource
    
    var body: some View {
        VStack {
            Text(title)
            Button("Next Step") {
                path.nextStep()
            }
        }
    }
}


/// A `ManagedNavigationStack` without an external path or start step.
///
/// The stack configures its path only after its body was first evaluated.
/// Nothing in this view causes a later update, so the first step only shows up if that configuration itself updates the view.
struct PlainManagedNavigationStackTestView: View {
    var body: some View {
        ManagedNavigationStack {
            PlainStep(title: "Plain Step 1")
            PlainStep(title: "Plain Step 2")
        }
    }
}
