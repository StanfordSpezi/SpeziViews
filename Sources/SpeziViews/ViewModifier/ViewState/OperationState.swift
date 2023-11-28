//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


/// The ``OperationState`` protocol is used to map the state of an operation, for example a specific action or a more complex task being performed,
/// to a SpeziView ``ViewState``, describing the current state of a SwiftUI `View`.
///
/// Combined with the ``SwiftUI/View/map(state:to:)`` view modifier, the ``OperationState`` provides an easy-to-use
/// bridging mechanism between the state of an operation and a SpeziViews ``ViewState``. One should highlight that this bridging is only done
/// in one direction, so the data flow from the ``OperationState`` towards the ``ViewState``, not the other way around, the reason being that
/// the state of a SwiftUI `View` doesn't influence the state of some arbitrary operation.
///
/// # Usage
///
/// ```swift
/// public enum DownloadState {
///     case ready
///     case downloading(progress: Double)
///     case error(LocalizedError)
///     ...
/// }
///
/// // Map the `DownloadState` to an `ViewState`
/// extension DownloadState: OperationState {
///     public var viewState: ViewState {
///         switch self {
///             case .ready:
///                 .idle
///             case .downloading:
///                 .processing
///             case .error(let error):
///                 .error(error)
///             ...
///         }
///     }
/// }
///
/// struct StateTestView: View {
///     @State private var downloadState: DownloadState = .ready
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
public protocol OperationState {
    var viewState: ViewState { get }
}
