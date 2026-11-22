//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct DismissButtonTestView: View {
    @State private var showSheet = false
    
    var body: some View {
        Form {
            Button("Show Sheet") {
                showSheet = true
            }
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                Text("This is the Sheet")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            DismissButton()
                        }
                    }
            }
        }
    }
}
