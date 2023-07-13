//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

private struct ProcessingOverlay<Overlay: View>: ViewModifier {
    fileprivate var isProcessing: Bool
    @ViewBuilder fileprivate var overlay: () -> Overlay

    func body(content: Content) -> some View {
        content
            .opacity(isProcessing ? 0.0 : 1.0)
            .overlay {
                if isProcessing {
                    overlay()
                }
            }
    }
}

extension View {
    /// Modifies the view to be replaced by an processing indicator based on the supplied condition.
    /// - Parameters:
    ///   - state: The `ViewState` that is used to determine whether the view is replaced by the processing overlay.
    ///         We consider the view to be processing if the state is ``ViewState/processing``.
    ///   - overlay: A view which which the modified view is overlayed with when state is processing.
    /// - Returns: A view that may render processing state.
    public func processingOverlay<Overlay: View>(
        isProcessing state: ViewState,
        @ViewBuilder overlay: @escaping () -> Overlay = { ProgressView() }
    ) -> some View {
        processingOverlay(isProcessing: state == .processing, overlay: overlay)
    }

    /// Modifies the view to be replaced by an processing indicator based on the supplied condition.
    /// - Parameters:
    ///   - processing: A Boolean value that determines whether the view is replaced by the processing overlay.
    ///   - overlay: A view which which the modified view is overlayed with when state is processing.
    /// - Returns: A view that may render processing state.
    public func processingOverlay<Overlay: View>(
        isProcessing processing: Bool,
        @ViewBuilder overlay: @escaping () -> Overlay = { ProgressView() }
    ) -> some View {
        modifier(ProcessingOverlay(isProcessing: processing, overlay: overlay))
    }
}
