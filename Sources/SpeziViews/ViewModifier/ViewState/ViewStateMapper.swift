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
            .onChange(of: operationState.representation) {
                viewState = operationState.representation
            }
    }
}


extension View {
    /// Continuously maps a state conforming to the ``OperationState`` protocol to a separately stored ``ViewState``.
    /// 
    /// Used to propagate the ``ViewState`` representation of the ``OperationState`` (so ``OperationState/representation``) to a ``ViewState`` that lives within a SwiftUI `View`.
    ///
    /// ### Usage
    /// ```swift
    /// struct OperationStateTestView: View {
    ///     @State private var downloadState: DownloadState = .ready    // `DownloadState` conforms to `OperationState`
    ///     @State private var viewState: ViewState = .idle
    ///
    ///     var body: some View {
    ///         Text("Operation State: \(String(describing: operationState))")
    ///             .map(state: downloadState, to: $viewState)  // Map the `DownloadState` to the `ViewState`
    ///             .viewStateAlert(state: $viewState)  // Show alerts based on the derived `ViewState`
    ///             .task {
    ///                 // Changes to the `DownloadState` which are automatically mapped to the `ViewState`
    ///                 // ...
    ///             }
    ///     }
    /// }
    /// ```
    ///
    /// - Note: The ``OperationState`` documentation contains a complete example using the ``SwiftUI/View/map(state:to:)`` view modifier.
    ///
    /// > Tip:
    /// > In the case that no SwiftUI `Binding` to the ``ViewState`` of the ``OperationState`` (so ``OperationState/representation``)
    /// > is required (e.g., no use of the ``SwiftUI/View/viewStateAlert(state:)-4wzs4`` view modifier), one is able to omit the separately defined ``ViewState``
    /// > within a SwiftUI `View` and directly access the ``OperationState/representation`` property.
    ///
    /// - Parameters:
    ///    - operationState: The source ``OperationState`` that should be mapped to the SpeziViews ``ViewState``.
    ///    - viewState: A `Binding` to the to-be-written-to ``ViewState``.
    public func map<T: OperationState>(state operationState: T, to viewState: Binding<ViewState>) -> some View {
        self
            .modifier(ViewStateMapper(operationState: operationState, viewState: viewState))
    }
}
