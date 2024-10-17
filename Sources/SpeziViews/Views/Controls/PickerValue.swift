//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
import SwiftUI


/// A type that can be rendered as a picker (like enum values).
///
/// Conform your type to [`CaseIterable`](https://developer.apple.com/documentation/swift/caseiterable)
/// to enumerate all cases, [`CustomLocalizedStringResourceConvertible`](https://developer.apple.com/documentation/foundation/customlocalizedstringresourceconvertible)
/// to provide a localizable representation for each case and [`Hashable`](https://developer.apple.com/documentation/swift/hashable)
/// to differentiate cases.
public typealias PickerValue = CaseIterable & CustomLocalizedStringResourceConvertible & Hashable


extension Optional: @retroactive CaseIterable where Wrapped: CaseIterable {
    public static var allCases: [Wrapped?] {
        [nil] + Wrapped.allCases.map { .some($0) }
    }
}


extension Optional: @retroactive CustomLocalizedStringResourceConvertible where Wrapped: CustomLocalizedStringResourceConvertible {
    public var localizedStringResource: LocalizedStringResource {
        switch self {
        case .none:
            LocalizedStringResource("None", bundle: .atURL(from: .module))
        case let .some(value):
            value.localizedStringResource
        }
    }
}
