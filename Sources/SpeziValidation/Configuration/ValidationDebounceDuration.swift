//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ValidationDebounceDurationKey: EnvironmentKey {
    static let defaultValue: Duration = .seconds(0.5)
}


extension EnvironmentValues {
    public var validationDebounce: Duration {
        get {
            self[ValidationDebounceDurationKey.self]
        }
        set {
            self[ValidationDebounceDurationKey.self] = newValue
        }
    }
}