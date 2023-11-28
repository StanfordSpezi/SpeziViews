//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The ``OperationState`` protocol provides a broad meta model for the current state of a specific action or task conducted within the Spezi ecosystem.
/// An ``OperationState`` is based upon a state of a typical finite automata which has a well-defined start and end state, such as an error state or a result state.
///
/// An example conformance to the ``OperationState`` protocol is showcased in the code snippet below which presents the state of a download task.
///
/// ```swift
/// public enum DownloadState: OperationState {
///     case ready
///     case downloading(progress: Double)
///     case error(LocalizedError)
///     ...
/// }
/// ```
///
/// ### Representation as a ViewState
///
/// The ``OperationState`` encapsulates the core state of an application's behavior, which directly impacts the user interface and interaction.
/// To effectively manage the UI's state in the Spezi framework, the ``OperationState`` can be represented as a ``ViewState``.
/// This bridging mechanism allows Spezi to monitor and respond to changes in the view's state, for example via the ``SwiftUI/View/viewStateAlert(state:)`` view modifier.
///
/// - Note: It's important to note that this conversion is a lossy process, where a potentially intricate ``OperationState`` is
/// distilled into a simpler ``ViewState``.
/// One should highlight that this bridging is only done in one direction, so from the ``OperationState`` towards the ``ViewState``,
/// the reason being that the state of a SwiftUI `View` doesn't influence the state of some arbitrary operation.
///
/// ```swift
/// extension DownloadState {
///     public var representation: ViewState {
///         switch self {
///             case .ready:
///                 .idle
///             case .downloading:
///                 .processing
///             case .error(let error):
///                 .error(error)
///             // ...
///         }
///     }
/// }
///
/// struct OperationStateTestView: View {
///     @State private var downloadState: DownloadState = .ready
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
public protocol OperationState {
    /// Defines the lossy abstraction logic from the possibly complex ``OperationState`` to the simple ``ViewState``.
    var representation: ViewState { get }
}
