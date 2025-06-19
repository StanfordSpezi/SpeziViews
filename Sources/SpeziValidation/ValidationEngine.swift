//
// This source file is part of the Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SpeziFoundation
import SwiftUI


/// A model that is responsible to verify a list of ``ValidationRule``s.
///
/// You may use a `ValidationEngine` inside your view hierarchy (using [@StateObject](https://developer.apple.com/documentation/swiftui/stateobject)
/// to manage the evaluation of your ``ValidationRule``s. The Engine provides easy access to bindings for current validity state of a the
/// processed input and a the respective recovery suggestions for failed ``ValidationRule``s.
/// The state of the `ValidationEngine` is updated on each invocation of ``runValidation(input:)`` or ``submit(input:debounce:)``.
@Observable
@MainActor
public final class ValidationEngine: Identifiable {
    /// Determines the source of the last validation run.
    private enum Source: Equatable {
        /// The last validation was run due to change in text field or keyboard submit.
        case submit
        /// The last validation was run due to manual interaction (e.g., a button press).
        case manual
    }

    private enum Event {
        case validateInput(String)
    }


    private static let logger = Logger(subsystem: "edu.stanford.spezi.validation", category: "ValidationEngine")


    /// Unique identifier for this validation engine.
    public nonisolated var id: ObjectIdentifier {
        ObjectIdentifier(self)
    }

    /// Access to the underlying validation rules.
    public let validationRules: [ValidationRule]

    @MainActor private var computedInputValid: Bool? // swiftlint:disable:this discouraged_optional_boolean

    /// A property that indicates if the last processed input is considered valid given the supplied ``ValidationRule`` list.
    ///
    /// The behavior when no input was provided yet (a validation that was never executed) is being
    /// can be influenced using the ``ValidationEngine/Configuration-swift.struct/considerNoInputAsValid`` configuration.
    /// By default no input is treated as being invalid.
    @MainActor public var inputValid: Bool {
        if let computedInputValid {
            return computedInputValid
        }

        return configuration.contains(.considerNoInputAsValid)
    }

    /// A list of ``FailedValidationResult`` for the processed input, providing, e.g., recovery suggestions.
    @MainActor public private(set) var validationResults: [FailedValidationResult] = []

    /// Stores the source of the last validation execution. `nil` if validation was never run.
    private var source: Source?
    /// Input was empty. By default we consider no input as empty input.
    private var inputWasEmpty = true

    /// Flag that indicates if ``displayedValidationResults`` returns any ``FailedValidationResult``.
    @MainActor public var isDisplayingValidationErrors: Bool {
        let gotResults = !validationResults.isEmpty

        if configuration.contains(.hideFailedValidationOnEmptySubmit) {
            return gotResults && (source == .manual || !inputWasEmpty)
        }

        return gotResults
    }


    /// A list of ``FailedValidationResult`` for the processed input that should be used by UI components.
    ///
    /// In certain scenarios it might the desirable to not display any validation results if the user erased the whole
    /// input field. You can achieve this by setting the ``ValidationEngine/Configuration-swift.struct/hideFailedValidationOnEmptySubmit`` option
    /// and using the ``submit(input:debounce:)`` method.
    ///
    /// - Note: When calling ``runValidation(input:)`` (e.g., on the button action) this field always delivers
    ///     the same results as the ``validationResults`` property.
    @MainActor public var displayedValidationResults: [FailedValidationResult] {
        isDisplayingValidationErrors ? validationResults : []
    }

    /// Access the configuration of the validation engine.
    ///
    /// You may use the ``SwiftUICore/EnvironmentValues/validationConfiguration`` environment key to configure this value from
    /// the environment.
    public var configuration: Configuration
    /// The configurable debounce duration for input submission.
    ///
    /// This duration is used to debounce repeated calls to ``submit(input:debounce:)`` where `debounce` is set to `true`.
    /// You may use the ``SwiftUICore/EnvironmentValues/validationDebounce`` environment key to configure this value from
    /// the environment.
    public var debounceDuration: Duration

    private var events: (stream: AsyncStream<Event>, continuation: AsyncStream<Event>.Continuation) = AsyncStream.makeStream()


    /// Initialize a new `ValidationEngine` by providing a list of ``ValidationRule``s.
    ///
    /// - Parameters:
    ///   - validationRules: An array of validation rules.
    ///   - debounceDuration: The debounce duration used with ``submit(input:debounce:)`` and `debounce` set to `true`.
    ///   - configuration: The ``Configuration`` of the validation engine.
    init(
        rules validationRules: [ValidationRule],
        debounceFor debounceDuration: Duration = ValidationDebounceDurationKey.defaultValue,
        configuration: Configuration = []
    ) {
        self.debounceDuration = debounceDuration
        self.validationRules = validationRules
        self.configuration = configuration
    }

    /// Initialize a new `ValidationEngine` by providing a list of ``ValidationRule``s.
    ///
    /// - Parameters:
    ///   - validationRules: A variadic array of validation rules.
    ///   - debounceDuration: The debounce duration used with ``submit(input:debounce:)`` and `debounce` set to `true`.
    ///   - configuration: The ``Configuration`` of the validation engine.
    package convenience init(
        rules validationRules: ValidationRule...,
        debounceFor debounceDuration: Duration = ValidationDebounceDurationKey.defaultValue,
        configuration: Configuration = []
    ) {
        self.init(rules: validationRules, debounceFor: debounceDuration, configuration: configuration)
    }

    private func computeFailedValidations(input: String) -> [FailedValidationResult] {
        var results: [FailedValidationResult] = []

        for rule in validationRules {
            if let failedValidation = rule.validate(input) {
                results.append(failedValidation)
                Self.logger.trace("Validation for input '\(input.description, privacy: .public)' failed with reason: \(failedValidation.localizedStringResource.localizedString(), privacy: .public)")

                if rule.effect == .intercept {
                    break
                }
            }
        }

        return results
    }


    private func computeValidation(input: String, source: Source) {
        self.source = source
        self.inputWasEmpty = input.isEmpty

        self.validationResults = computeFailedValidations(input: input)
        self.computedInputValid = validationResults.isEmpty
    }

    /// Runs all validations for a given input on text field submission or value change.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed or the input is empty. This is particularly
    /// useful to reset go back to a valid state if the user submits a empty string in the text field.
    /// Make sure to run ``runValidation(input:)`` one last time to process the data (e.g., on a button action).
    ///
    /// - Parameters:
    ///   - input: The input to validate.
    ///   - debounce: If set to `true`, calls to this method will be "debounced". The validation will not run as long as
    ///     there are no further calls to this method for the configured ``debounceDuration``. If set to `false` the method
    ///     will run immediately. Note that the validation will still run instantly, if we are currently in an invalid state
    ///     to ensure input validity is reported immediately.
    public func submit(input: String, debounce: Bool = false) {
        if !debounce || computedInputValid == false {
            // we compute instantly, if debounce is false or if we are in a invalid state
            computeValidation(input: input, source: .submit)
        } else {
            // otherwise, we debounce the debounce operation
            self.events.continuation.yield(.validateInput(input))
        }
    }

    /// Runs all validations for a given input.
    ///
    /// The input is considered valid if all ``ValidationRule``s succeed.
    /// - Parameter input: The input to validate.
    public func runValidation(input: String) {
        computeValidation(input: input, source: .manual)
    }

    @MainActor
    package func run() async {
        await withDiscardingTaskGroup { group in
            var runningTask: CancelableTaskHandle?

            for await event in events.stream {
                switch event {
                case let .validateInput(input):
                    runningTask?.cancel()
                    runningTask = group.addCancelableTask { @MainActor in
                        try? await Task.sleep(for: self.debounceDuration)
                        guard !Task.isCancelled else {
                            return
                        }
                        self.computeValidation(input: input, source: .submit)
                    }
                }
            }
        }

        events = AsyncStream.makeStream()
    }
}
