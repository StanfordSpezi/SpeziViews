//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ManagedNavigationStackTestView: View {
    var body: some View {
        ManagedNavigationStack {
            Step {
                Text("Hello")
                    .navigationTitle("ABC")
            }
            Step {
                Text("There")
                    .navigationTitle("DEF")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}


private struct Step<Content: View>: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    @ViewBuilder let content: @MainActor () -> Content
    
    var body: some View {
        VStack {
            Spacer()
            content()
            Spacer()
            Button("Next Step") {
                path.nextStep()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
