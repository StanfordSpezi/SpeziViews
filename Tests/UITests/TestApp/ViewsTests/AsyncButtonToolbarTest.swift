//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct AsyncButtonToolbarTestSheet: View {
    @State private var didTap = false
    
    var body: some View {
        NavigationStack {
            Form {
                LabeledContent("Did tap", value: didTap.description)
            }
            .navigationTitle("AsyncButtonInToolbar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    DismissButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    AsyncButton("Tap Me!") {
                        didTap = true
                    }
                }
            }
        }
    }
}
