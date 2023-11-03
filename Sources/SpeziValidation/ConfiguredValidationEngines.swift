//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


// TODO document
struct ConfiguredValidationEngines: PreferenceKey {
    static let defaultValue: [ValidationContext] = []

    static func reduce(value: inout [ValidationContext], nextValue: () -> [ValidationContext]) {
        value.append(contentsOf: nextValue())
    }
}


extension View {
    public func receiveValidationEngines(_ receive: @escaping ([ValidationContext]) -> Void) -> some View {
        onPreferenceChange(ConfiguredValidationEngines.self, perform: receive)
    }
}
