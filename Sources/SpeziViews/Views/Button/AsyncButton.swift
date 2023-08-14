//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


enum AsyncButtonState {
    case idle
    case disabled
    case disabledAndProcessing
}


/// A SwiftUI `Button` that initiates an asynchronous (throwing) action.
@MainActor
public struct AsyncButton<Label: View>: View {
    private let role: ButtonRole?
    private let action: () async throws -> Void
    private let label: () -> Label

    @Environment(\.defaultErrorDescription)
    var defaultErrorDescription
    @Environment(\.processingDebounceDuration)
    var processingDebounceDuration

    @State private var actionTask: Task<Void, Never>?

    @State private var buttonState: AsyncButtonState = .idle
    @Binding private var viewState: ViewState

    // this covers the case where the encapsulating view sets the viewState binding to processing.
    // This should also make the button to rendered as processing!
    private var externallyProcessing: Bool {
        buttonState == .idle && viewState == .processing
    }

    public var body: some View {
        Button(role: role, action: submitAction) {
            label()
                .processingOverlay(isProcessing: buttonState == .disabledAndProcessing || externallyProcessing)
        }
            .disabled(buttonState != .idle || externallyProcessing)
            .onDisappear {
                actionTask?.cancel()
            }
    }

    /// Creates am async button that generates its label from a provided localized string.
    /// - Parameters:
    ///   - title: The localized string used to generate the Label.
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - action: An asynchronous button action.
    public init(
        _ title: LocalizedStringResource,
        role: ButtonRole? = nil,
        action: @escaping () async -> Void
    ) where Label == Text {
        self.init(role: role, action: action) {
            Text(title)
        }
    }
    
    /// Creates am async button that generates its label from a provided without localization.
    /// - Parameters:
    ///   - title: The string used to generate the Label without localization.
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - action: An asynchronous button action.
    @_disfavoredOverload
    public init<Title: StringProtocol>(
        _ title: Title,
        role: ButtonRole? = nil,
        action: @escaping () async -> Void
    ) where Label == Text {
        self.init(role: role, action: action) {
            Text(title)
        }
    }

    /// Creates an async button that displays a custom label.
    /// - Parameters:
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - action: An asynchronous button action.
    ///   - label: The Button label.
    public init(
        role: ButtonRole? = nil,
        action: @escaping () async -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self.action = action
        self.label = label
        self._viewState = .constant(.idle)
    }

    /// Creates an async throwing button that generates its label from a provided without localization.
    /// - Parameters:
    ///   - title: The string without localization used to generate the Label.
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - state: A ``ViewState`` binding that it used to propagate any error caught in the button action.
    ///         It may also be used to externally control or observe the button's processing state.
    ///   - action: An asynchronous button action.
    @_disfavoredOverload
    public init<Title: StringProtocol>( // swiftlint:disable:this function_default_parameter_at_end
        _ title: Title,
        role: ButtonRole? = nil,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void
    ) where Label == Text {
        self.init(role: role, state: state, action: action) {
            Text(title)
        }
    }
    
    /// Creates an async throwing button that generates its label from a provided localized string.
    /// - Parameters:
    ///   - title: The localized string used to generate the Label.
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - state: A ``ViewState`` binding that it used to propagate any error caught in the button action.
    ///         It may also be used to externally control or observe the button's processing state.
    ///   - action: An asynchronous button action.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        _ title: LocalizedStringResource,
        role: ButtonRole? = nil,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void
    ) where Label == Text {
        self.init(role: role, state: state, action: action) {
            Text(title)
        }
    }

    /// Creates an async button that displays a custom label.
    /// - Parameters:
    ///   - role: An optional button role that is passed onto the underlying `Button`.
    ///   - state: A ``ViewState`` binding that it used to propagate any error caught in the button action.
    ///         It may also be used to externally control or observe the button's processing state.
    ///   - action: An asynchronous button action.
    ///   - label: The Button label.
    public init( // swiftlint:disable:this function_default_parameter_at_end
        role: ButtonRole? = nil,
        state: Binding<ViewState>,
        action: @escaping () async throws -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.role = role
        self._viewState = state
        self.action = action
        self.label = label
    }


    private func submitAction() {
        guard viewState != .processing else {
            return
        }

        buttonState = .disabled

        withAnimation(.easeOut(duration: 0.2)) {
            viewState = .processing
        }

        actionTask = Task {
            do {
                let debounce = Task {
                    try await debounceProcessingIndicator()
                }

                try await action()
                debounce.cancel()

                // the button action might set the state back to idle to prevent this animation
                if viewState != .idle {
                    withAnimation(.easeIn(duration: 0.2)) {
                        viewState = .idle
                    }
                }
            } catch {
                viewState = .error(AnyLocalizedError(
                    error: error,
                    defaultErrorDescription: defaultErrorDescription
                ))
            }

            buttonState = .idle
            actionTask = nil
        }
    }

    private func debounceProcessingIndicator() async throws {
        try await Task.sleep(for: processingDebounceDuration)

        // this is actually important to catch cases where the action runs a tiny bit faster than the debounce timer
        guard !Task.isCancelled else {
            return
        }

        withAnimation(.easeOut(duration: 0.2)) {
            buttonState = .disabledAndProcessing
        }
    }
}


#if DEBUG
struct AsyncThrowingButton_Previews: PreviewProvider {
    struct PreviewButton: View {
        var title: LocalizedStringResource = "Test Button"
        var role: ButtonRole?
        var duration: Duration = .seconds(1)
        var action: () async throws -> Void = {}

        @State var state: ViewState = .idle

        var body: some View {
            AsyncButton(title, role: role, state: $state) {
                try await Task.sleep(for: duration)
                try await action()
            }
                .viewStateAlert(state: $state)
        }
    }

    static var previews: some View {
        Group {
            PreviewButton()
            PreviewButton(title: "Test Button with short action", duration: .milliseconds(100))
            /*AsyncThrowingButton(state: $state, action: { print("button pressed") }) {
                Text("Test Button!")
            }*/
            PreviewButton(title: "Test Button with Error") {
                throw CancellationError()
            }

            PreviewButton(title: "Processing only Button", state: .processing)

            PreviewButton(title: "Destructive Button", role: .destructive)
        }
            .buttonStyle(.borderedProminent)
    }
}
#endif
