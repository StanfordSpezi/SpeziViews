//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


extension ManagedNavigationStack {
    /// A result builder used to aggregate multiple SwiftUI `View`s within the ``ManagedNavigationStack``.
    @resultBuilder
    public enum StepsBuilder {
        /// Navigation Flow Element
        public typealias Element = StepsCollection.Element
        
        /// If declared, provides contextual type information for statement expressions to translate them into partial results.
        public static func buildExpression(
            _ view: some View,
            _ fileId: StaticString = #fileID,
            _ line: UInt = #line,
            _ column: UInt = #column
        ) -> [Element] {
            [Element(view: view, sourceLocation: .init(fileId: fileId, line: line, column: column))]
        }
        
        /// Required by every result builder to build combined results from statement blocks.
        public static func buildBlock(_ children: [Element]...) -> [Element] {
            children.flatMap { $0 }
        }
        
        /// Enables support for `if` statements that do not have an `else`.
        public static func buildOptional(_ elements: [Element]?) -> [Element] {
            // swiftlint:disable:previous discouraged_optional_collection
            // The optional collection is a requirement defined by @resultBuilder, we can not use a non-optional collection here.
            elements ?? []
        }
        
        /// With buildEither(second:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
        public static func buildEither(first: [Element]) -> [Element] {
            first
        }
        
        /// With buildEither(first:), enables support for 'if-else' and 'switch' statements by folding conditional results into a single result.
        public static func buildEither(second: [Element]) -> [Element] {
            second
        }
        
        /// If declared, this will be called on the partial result of an 'if #available' block to allow the result builder to erase type information.
        public static func buildLimitedAvailability(_ elements: [Element]) -> [Element] {
            elements
        }
        
        /// `for` loop support.
        @available(
            *,
             unavailable,
             message: "The ManagedNavigationStack doesn't allow `for` loops in its content builder, since that would mess up the step identification logic."
             // swiftlint:disable:previous line_length
        )
        public static func buildArray(_ components: [[Element]]) -> [Element] {
            fatalError("Unavailable")
        }
        
        /// If declared, this will be called on the partial result from the outermost block statement to produce the final returned result.
        public static func buildFinalResult(_ elements: [Element]) -> StepsCollection {
            StepsCollection(elements: elements)
        }
    }
}
