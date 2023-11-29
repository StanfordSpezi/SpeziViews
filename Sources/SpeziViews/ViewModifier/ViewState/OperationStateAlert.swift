//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct OperationStateAlert<T: OperationState>: ViewModifier {
    private let operationState: T
    @State private var viewState: ViewState
    
    init(operationState: T) {
        self.operationState = operationState
        self._viewState = State(wrappedValue: operationState.representation)
    }
    
    
    func body(content: Content) -> some View {
        content
            .map(state: operationState, to: $viewState)
            .viewStateAlert(state: $viewState)
    }
}


extension View {
    /// Automatically displays an alert using the localized error descriptions based on an ``ViewState``  derived from a ``OperationState``.
    /// - Parameter state: The ``OperationState`` from which the ``ViewState`` is derived.
    public func viewStateAlert<T: OperationState>(state: T) -> some View {
        self
            .modifier(OperationStateAlert(operationState: state))
    }
}
