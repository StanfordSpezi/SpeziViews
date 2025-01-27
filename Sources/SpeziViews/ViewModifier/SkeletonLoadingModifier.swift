//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


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
///                         .fill(secondaryColor)
///                         .frame(height: 100)
///                         .skeletonLoading(replicationCount: 5, repeatInterval: 1.5)
///                 }
///         }
///     }
/// }
/// ```
///
/// - Parameters:
///   - replicationCount: The number of skeleton cells to display.
///   - repeatInterval: The repeat interval for the shimmer animation.
struct SkeletonLoadingViewModifier: ViewModifier {
    var replicationCount: Int
    var shimmerRepeatInterval: Double

    
    func body(content: Content) -> some View {
        VStack(spacing: 16) {
            ForEach(0..<replicationCount, id: \.self) { _ in
                content
                    .redacted(reason: .placeholder)
            }
        }
            .mask(
                LinearGradient(gradient: Gradient(colors: [.secondary, .clear]), startPoint: .top, endPoint: .bottom)
            )
            .shimmer(repeatInterval: shimmerRepeatInterval)
    }
}


extension View {
    /// Adds a skeleton loading effect to the view.
    ///
    /// This modifier can be used to display a loading state while content is being fetched.
    /// It replicates the provided view vertically a specified number of times and applies a shimmer effect.
    ///
    /// - Parameters:
    ///   - replicationCount: The number of skeleton cells to display (default is 1).
    ///   - repeatInterval: The repeat interval for the shimmer animation (default is 1 second).
    /// - Returns: A view with the skeleton loading effect applied.
    public func skeletonLoading(replicationCount: Int = 1, repeatInterval: Double = 1) -> some View {
        modifier(SkeletonLoadingViewModifier(replicationCount: replicationCount, shimmerRepeatInterval: repeatInterval))
    }
}
