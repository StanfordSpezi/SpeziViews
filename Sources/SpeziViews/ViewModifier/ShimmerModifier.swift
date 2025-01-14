//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct ShimmerViewModifier: ViewModifier {
    let repeatInterval: Double
    @State private var shimmering: Bool = false

    
    func body(content: Content) -> some View {
        content
            .opacity(shimmering ? 0.3 : 1)
            .animation(.easeInOut(duration: repeatInterval).repeatForever(), value: shimmering)
            .onAppear {
                shimmering.toggle()
            }
    }
}

extension View {
    /// Applies a shimmer animation to the view.
    ///
    /// This modifier is useful, e.g., in combination with the ``ProcessingOverlay`` when
    /// used with a asynchronosly loaded view. This allows to implement a skeleton loading effect.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// struct ShimmerModifierTestView: View {
    ///     @State var loading = false
    ///     let secondaryColor = Color(.init(gray: 0.8, alpha: 1.0))
    ///
    ///     var body: some View {
    ///         VStack {
    ///             ExampleAsyncView(loading: $loading)
    ///                 .processingOverlay(isProcessing: loading) {
    ///                     RoundedRectangle(cornerRadius: 10)
    ///                         .fill(secondaryColor)
    ///                         .frame(height: 100)
    ///                         .shimmer(repeatInterval: 1.5)
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - repeatInterval: The repeat interval for the shimmer animation.
    /// - Returns: The modified view.
    public func shimmer(repeatInterval: Double = 1) -> some View {
        modifier(ShimmerViewModifier(repeatInterval: repeatInterval))
    }
}
