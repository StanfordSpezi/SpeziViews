//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct ManagedViewStateTests: View {
    private final class State {
        var state: Int = 0
    }

    // deliberately do not make it observable
    private let state = State()

    @ManagedViewUpdate private var viewUpdate

    var body: some View {
        List {
            Section("State") {
                ListRow("Value") {
                    Text("\(state.state)")
                }
                Button("Increment") {
                    state.state += 1
                }
            }

            Button("Refresh") {
                viewUpdate.refresh()
            }
            Button("Refresh in 2s") {
                viewUpdate.schedule(at: Date.now.addingTimeInterval(2))
            }
        }
            .navigationTitle("Managed View Update")
    }

    init() {}
}


#if DEBUG
#Preview {
    ManagedViewStateTests()
}
#endif
