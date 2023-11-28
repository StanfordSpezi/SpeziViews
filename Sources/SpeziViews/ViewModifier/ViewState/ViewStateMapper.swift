//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct ViewStateMapper<T: OperationState>: ViewModifier {
    private let operationState: T
    @Binding private var viewState: ViewState
    
    
    init(operationState: T, viewState: Binding<ViewState>) {
        self.operationState = operationState
        self._viewState = viewState
    }
    
    
    func body(content: Content) -> some View {
        content
            .onChange(of: operationState.viewState) {
                viewState = operationState.viewState
            }
    }
}


extension View {
    /// Maps a state conforming to the ``OperationState`` protocol to a SpeziViews ``ViewState``.
    ///
    /// # Usage
    /// ```swift
    /// struct StateTestView: View {
    ///     @State private var downloadState: DownloadState = .ready    // Conforms to the ``OperationState`` protocol
    ///     @State private var viewState: ViewState = .idle
    ///
    ///     var body: some View {
    ///         EmptyView()
    ///             // Map the `DownloadState` to the `ViewState`
    ///             .map(state: downloadState, to: $viewState)
    ///             // Show alerts based on the `ViewState`
    ///             .viewStateAlert(state: $viewState)
    ///             .task {
    ///                 // Changes to the `DownloadState`
    ///                 ...
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// # Note
    /// The ``OperationState`` documentation contains a complete example using the ``SwiftUI/View/map(state:to:)`` view modifier.
    ///
    /// - Parameters:
    ///    - operationState: The source ``OperationState`` that should be mapped to the SpeziViews ``ViewState``.
    ///    - viewState: A `Binding` to the to-be-written-to ``ViewState``.
    public func map<T: OperationState>(state operationState: T, to viewState: Binding<ViewState>) -> some View {
        self
            .modifier(ViewStateMapper(operationState: operationState, viewState: viewState))
    }
}
