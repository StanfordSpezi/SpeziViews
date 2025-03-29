//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation
import SwiftUI


/// Defines a collection of SwiftUI `View`s that are defined with a ``ManagedNavigationStack``.
///
/// - Note: You do not create instances of `_NavigationFlow` yourself; this type is used internally by the ``ManagedNavigationStack``.
public class _NavigationFlow {  // swiftlint:disable:this type_name
    /// An element collected by the ``NavigationFlowBuilder``.
    public struct Element {
        struct SourceLocation: Hashable, Sendable {
            let fileId: StaticString
            let line: UInt
            let column: UInt
        }
        let view: any View
        let sourceLocation: SourceLocation?
    }
    
    let elements: [Element]
    
    init(elements: [Element]) {
        self.elements = elements
    }
}
