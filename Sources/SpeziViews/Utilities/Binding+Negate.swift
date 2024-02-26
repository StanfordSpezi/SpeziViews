//
// This source file is part of the Stanford Spezi project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension Binding where Value == Bool {
    /// Negates a SwiftUI `Binding`.
    ///
    /// ### Usage
    ///
    /// The example below demonstrates a minimal use case of a negated SwiftUI `Binding` by toggling a shared boolean state in different `View`s.
    ///
    /// ```swift
    /// struct ParentView: View {
    ///     @State var isOn: Bool = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             Button(isOn ? "Turn Off" : "Turn On") {
    ///                 isOn.toggle()
    ///             }
    ///
    ///             // Pass an inverted `Binding` to the `ChildView`.
    ///             ChildView(isOff: !$isOn)
    ///         }
    ///    }
    /// }
    ///
    /// struct ChildView: View {
    ///     @Binding var isOff: Bool
    ///
    ///     var body: some View {
    ///         Button("Toggle from Child View") {
    ///             isOff.toggle()
    ///         }
    ///     }
    /// }
    /// ```
    public prefix static func ! (value: Binding<Bool>) -> Binding<Bool> {
        Binding<Bool>(
            get: { !value.wrappedValue },
            set: { value.wrappedValue = !$0 }
        )
    }
}
