//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation

extension LocalizedStringResource {
    /// Creates a localized `String` from the given `LocalizedStringResource`.
    public func localizedString() -> String {
        String(localized: self)
    }
}
