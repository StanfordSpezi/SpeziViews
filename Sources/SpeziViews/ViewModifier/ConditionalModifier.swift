//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// struct ConditionalModifierTestView: View {
    ///     @State var condition = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Text("Condition present")
    ///                 .if(condition) { view in
    ///                     view
    ///                         .hidden()
    ///                 }
    ///
    ///             Button("Toggle Condition") {
    ///                 condition.toggle()
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder public func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// Applies the given transform if the given condition closure evaluates to `true`.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// struct ConditionalModifierTestView: View {
    ///     @State var closureCondition = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Text("Closure Condition present")
    ///                 .if(condition: {
    ///                     closureCondition
    ///                 }, transform: { view in
    ///                     view
    ///                         .hidden()
    ///                 })
    ///
    ///             Button("Toggle Closure Condition") {
    ///                 closureCondition.toggle()
    ///             }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - condition: The condition closure to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition closure is `true`.
    @ViewBuilder public func `if`<Content: View>(condition: () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
}
