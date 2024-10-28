//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


enum SomeSelection: PickerValue {
    case first
    case second

    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .first:
            "First"
        case .second:
            "Second"
        }
    }
}


struct CaseIterablePickerTests: View {
    @State private var selection: SomeSelection?

    var body: some View {
        List {
            CaseIterablePicker("Selection", selection: $selection)
        }
            .navigationTitle("Case Iterable Picker")
            .navigationBarTitleDisplayMode(.inline)
    }
}
