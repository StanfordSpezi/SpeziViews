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
    /// A view modifier that applies a shimmer animation effect.
    ///
    /// The `ShimmerViewModifier` applies a simple opacity animation that creates a shimmer effect.
    /// It can be useful when displaying placeholders for content that is being asynchronously loaded.
    /// The `SkeletonLoadingModifier` combines this with a vertical replication of the view to create a skeleton loading effect.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// struct ShimmerModifierTestView: View {
    ///     @State var loading = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             ExampleAsyncView(loading: $loading)
    ///                 .processingOverlay(isProcessing: loading) {
    ///                     RoundedRectangle(cornerRadius: 10)
    ///                         .fill(Color(UIColor.systemGray4))
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
        modifier(ShimmerViewModifier(repeatInterval: max(0, repeatInterval)))
    }
}
