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

struct MyOptionSet: OptionSet, PickerValue {
    static let option1 = MyOptionSet(rawValue: 1 << 0)
    static let option2 = MyOptionSet(rawValue: 1 << 1)

    static let allCases: [MyOptionSet] = [.option1, .option2]

    var rawValue: UInt8

    var localizedStringResource: LocalizedStringResource {
        var components: [String] = []

        if self.contains(.option1) {
            components.append("Option 1")
        }
        if self.contains(.option2) {
            components.append("Option 2")
        }

        return "\(components.joined(separator: ", "))"
    }


    init(rawValue: UInt8) {
        self.rawValue = rawValue
    }
}


struct CaseIterablePickerTests: View {
    @State private var selection: SomeSelection?

    @State private var selection2: SomeSelection = .first

    @State private var optionSetMenu: MyOptionSet = []

    var body: some View {
        List {
            CaseIterablePicker("Selection", selection: $selection)

            CaseIterablePicker("Second", selection: $selection2)

            Section {
                OptionSetPicker("Option Set", selection: $optionSetMenu)
            }

            OptionSetPicker("Inline Picker", selection: $optionSetMenu, style: .inline)
        }
            .navigationTitle("Picker")
            .navigationBarTitleDisplayMode(.inline)
    }
}


#if DEBUG
#Preview {
    CaseIterablePickerTests()
}
#endif
