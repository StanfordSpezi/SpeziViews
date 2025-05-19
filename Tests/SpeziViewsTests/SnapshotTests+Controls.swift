//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SnapshotTesting
@testable import SpeziViews
import SwiftUI
import Testing

extension SnapshotTests {
    struct Options: OptionSet, PickerValue {
        var localizedStringResource: LocalizedStringResource {
            "Option \(rawValue)"
        }
        var rawValue: UInt8
        static let allCases: [Options] = [.option1, .option2]

        static let option1 = Options(rawValue: 1 << 0)
        static let option2 = Options(rawValue: 1 << 1)
    }

    enum Version: PickerValue {
        case versionA
        case versionB

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .versionA:
                "A"
            case .versionB:
                "B"
            }
        }
    }

    @Test("Option Set Picker")
    func optionSetPicker() {
        let picker0 = List {
            OptionSetPicker("Clean", selection: .constant(Options.option1))
        }
        let picker1 = List {
            OptionSetPicker("Code", selection: .constant(Options.option1.union(.option2)), style: .inline, allowEmptySelection: true)
        }

#if os(iOS)
        assertSnapshot(of: picker0, as: .image(layout: .device(config: .iPhone13Pro)), named: "option-picker")
        assertSnapshot(of: picker1, as: .image(layout: .device(config: .iPhone13Pro)), named: "option-picker-inline")
#endif
    }

    @Test("Case Iterable Picker")
    func caseIterablePicker() {
        let picker = List {
            CaseIterablePicker("Clean Code", selection: .constant(Version.versionA))
        }

#if os(iOS)
        assertSnapshot(of: picker, as: .image(layout: .device(config: .iPhone13Pro)), named: "iphone-regular")
#endif
    }
}
