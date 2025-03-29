//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


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
            .frame(maxWidth: .infinity, minHeight: 52)
        }
    }
}


struct ManagedNavigationStackTestView: View {
    @State var skipConditionalView = true
    @State var path = ManagedNavigationStack.Path()
    @State var counter = 0
    
    var body: some View {
        // TODO fix the bug where specifying the first view as the startAtStep param causes it to get pushed twice!
        // swiftlint:disable:next closure_body_length
        ManagedNavigationStack(path: path, startAtStep: .viewType(Step<Text>.self)) {
            Text("Step 0")
            Step {
                Text("Step 1")
            }
            Step {
                Text("Step 2")
            }
            Step {
                Text("Step 3")
                Toggle("Skip Next", isOn: $skipConditionalView)
            }
            if !skipConditionalView {
                Step {
                    Text("Step 4")
                }
            }
            Step {
                Text("Step 5")
                Button("Go to Step 7 (A)") {
                    path.moveToNextStep(matching: .identifier("step7"), includeIntermediateSteps: false)
                }
                Button("Go to Step 7 (B)") {
                    path.moveToNextStep(matching: .identifier("step7"), includeIntermediateSteps: true)
                }
                Button("Append Custom View") {
                    // TODO dismissing the custom step (via the back button) causes the IllegalStep view to get shown during the pop animation???
                    path.append(customView: Step { Text("Custom Step") })
                }
            }
            Step {
                Text("Step 6")
            }
            Step {
                Text("Step 7")
            }
            .navigationStepIdentifier("step7")
            Step {
                Text("Step 8")
                Button("Increment Counter") {
                    counter += 1
                }
            }
            if counter.isMultiple(of: 2) {
                Step {
                    Text("Step 9A (even)")
                }
            } else {
                Step {
                    Text("Step 9B (odd)")
                }
            }
        }
    }
}
