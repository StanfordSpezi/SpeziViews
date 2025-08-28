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


extension ManagedNavigationStack {
    /// A collection of navigation steps, as collected by the ``ManagedNavigationStack/StepsBuilder``.
    ///
    /// - Note: You do not create instances of `StepsCollection` yourself; this type is used internally by the ``ManagedNavigationStack``.
    @_documentation(visibility: internal)
    public final class StepsCollection {
        /// An element collected by the ``NavigationFlowBuilder``.
        public struct Element {
            struct SourceLocation: Hashable, Sendable { // swiftlint:disable:this nesting
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
}
