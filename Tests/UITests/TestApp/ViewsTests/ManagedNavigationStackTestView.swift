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


private struct Step3: View {
    @Binding var skipNext: Bool
    
    
    var body: some View {
        Step {
            Text("Step 3")
            Toggle("Skip Next", isOn: $skipNext)
        }
    }
}


struct ManagedNavigationStackTestView: View {
    @State var skipConditionalView = true
    @State var path = ManagedNavigationStack.Path()
    @State var counter = 0
    
    
    var body: some View {
        // swiftlint:disable:next closure_body_length
        ManagedNavigationStack(path: path, startAtStep: .viewType(Step<Text>.self)) {
            Text("Step 0")
            Step {
                Text("Step 1")
            }
            Step {
                Text("Step 2")
            }
            // We need to give this one its own separate view type, since mutating the @State variable from directly within here
            // somehow doesn't seem to work properly, but mutating it from w/in the other view, via a binding, does.
            // The weird thing is that the mutation itself does work, but the view won't get updated in response,
            // and will continue to display the old value.
            Step3(skipNext: $skipConditionalView)
            if !skipConditionalView {
                Step {
                    Text("Step 4")
                }
            }
            Step {
                Text("Step 5")
                Button("Go to Step 7 (A)") {
                    path.navigateToNextStep(matching: .identifier("step7"), includeIntermediateSteps: false)
                }
                Button("Go to Step 7 (B)") {
                    path.navigateToNextStep(matching: .identifier("step7"), includeIntermediateSteps: true)
                }
                Button("Append Custom View") {
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
                Form {
                    Text("Step 8")
                    Button("Increment Counter") {
                        counter += 1
                    }
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
