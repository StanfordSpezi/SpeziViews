//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct SkeletonLoadingViewModifier: ViewModifier {
    var replicationCount: Int
    var shimmerRepeatInterval: Double
    var spacing: CGFloat

    
    func body(content: Content) -> some View {
        VStack(spacing: spacing) {
            ForEach(0..<replicationCount, id: \.self) { _ in
                content
                    .redacted(reason: .placeholder)
            }
        }
            .shimmer(repeatInterval: shimmerRepeatInterval)
            .mask(
                LinearGradient(gradient: Gradient(colors: [.secondary, .clear]), startPoint: .top, endPoint: .bottom)
            )
    }
}


extension View {
    /// A view modifier for adding shimmering placeholder cells, often used as a loading state.
    ///
    /// The `SkeletonLoadingViewModifier` allows you to customize the number of cells,
    /// shimmer animation interval, and their appearance by applying it to any SwiftUI view.
    /// It can be useful when displaying placeholders for content that is being asynchronously loaded.
    ///
    /// ### Usage
    ///
    /// ```swift
    /// struct SkeletonLoadingTestView: View {
    ///     @State var loading = false
    ///
    ///     var body: some View {
    ///         VStack {
    ///             ExampleAsyncView(loading: $loading)
    ///                 .processingOverlay(isProcessing: loading) {
    ///                     RoundedRectangle(cornerRadius: 10)
    ///                         .frame(height: 100)
    ///                         .skeletonLoading(replicationCount: 5, repeatInterval: 1.5, spacing: 16)
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - replicationCount: The number of skeleton cells to display.
    ///   - repeatInterval: The repeat interval for the shimmer animation.
    ///   - spacing: The spacing between the skeleton cells.
    /// - Returns: A view with the skeleton loading effect applied.
    public func skeletonLoading(replicationCount: Int = 1, repeatInterval: Double = 1, spacing: CGFloat = 0) -> some View {
        modifier(SkeletonLoadingViewModifier(
            replicationCount: max(1, replicationCount),
            shimmerRepeatInterval: max(0, repeatInterval),
            spacing: max(0, spacing)
        ))
    }
}
