//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public struct SkeletonLoading<SkeletonCell: View>: View {
    var cellCount: Int
    var shimmerRepeatInterval: Double
    let skeletonCell: () -> SkeletonCell

    
    public var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<cellCount, id: \.self) { _ in
                skeletonCell()
            }
        }
            .mask(
                LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .top, endPoint: .bottom)
            )
            .shimmer(repeatInterval: shimmerRepeatInterval)
    }

    
    /// A view for vertically displaying shimmering placeholder cells, often used as a loading state.
    ///
    /// The `SkeletonLoading` view is customizable, allowing you to define the number of cells,
    /// shimmer animation interval, and cell appearance. For example, it can be used in combination
    /// with the `ProcessingOverlay` when working with an asynchronously loaded view.
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
    ///                     SkeletonLoading(cellCount: 5, shimmerRepeatInterval: 1.5) {
    ///                         RoundedRectangle(cornerRadius: 10)
    ///                         .fill(secondaryColor)
    ///                         .frame(height: 100)
    ///                     }
    ///                 }
    ///         }
    ///     }
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - cellCount: The number of skeleton cells to display.
    ///   - shimmerRepeatInterval: The repeat interval for the shimmer animation.
    ///   - skeletonCell: A closure returning the skeleton cell view.
    public init(cellCount: Int = 3, shimmerRepeatInterval: Double = 1, skeletonCell: @escaping () -> SkeletonCell) {
        self.cellCount = cellCount
        self.shimmerRepeatInterval = shimmerRepeatInterval
        self.skeletonCell = skeletonCell
    }
}
