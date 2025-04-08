//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import OrderedCollections
import SwiftUI


extension ManagedNavigationStack {
    /// Manages the current navigation state of a ``ManagedNavigationStack``.
    ///
    /// The ``Path`` keep track of the ``ManagedNavigationStack``'s current configuration, its position within its configuration, and handles navigation logic for advancing the stack.
    ///
    /// The ``Path`` also provides APIs for programmatic navigation within the ``ManagedNavigationStack``, enabling developers to easily define flow-like navigation structures
    /// without having to perform custom condition-based navigation logic within each step.
    ///
    /// The ``Path`` is injected as an environment object into the environment of the ``ManagedNavigationStack`` view hierarchy,
    /// allowing the individual navigation steps to access and control their containing ``ManagedNavigationStack``'s navigation.
    ///
    /// ## Topics
    /// ### Creating a `Path`
    /// - ``init()``
    ///
    /// ### Navigating within a `Path`
    /// - ``nextStep()``
    /// - ``navigateToNextStep(matching:includeIntermediateSteps:)``
    /// - ``append(customView:)``
    /// - ``removeLast()``
    @MainActor
    @Observable
    public final class Path {
        /// Used to match against navigation steps.
        public enum StepSelector {
            /// Matches against the first navigation step of the specified type.
            case viewType(any View.Type)
            /// Matches against the first navigation step with a custom identifier that matches the specified value.
            case identifier(any Hashable)
        }
        
        /// The actual path of the steps currently presented.
        var path: [NavigationStepIdentifier] = [] {
            didSet {
                // Remove dismissed custom steps when navigating backwards
                let removedSteps = oldValue.filter { !path.contains($0) }
                for step in removedSteps where step.isCustom {
                    customSteps.removeValue(forKey: step)
                }
            }
        }
        /// Boolean binding that is injected via the ``ManagedNavigationStack``.
        /// Indicates if the flow is completed, meaning the last view declared within the ``ManagedNavigationStack`` is completed.
        private var isComplete: Binding<Bool>?
        
        /// Stores all navigation steps as declared within the ``ManagedNavigationStack`` and keep them in order.
        @ObservationIgnored private var steps: OrderedDictionary<NavigationStepIdentifier, any View> = [:]
        /// Stores all custom navigation steps that are appended to the ``ManagedNavigationStack/Path``
        /// via the ``append(customView:)``  instance methods
        @ObservationIgnored private var customSteps: [NavigationStepIdentifier: any View] = [:]
        /// Indicates whether the Path's `configure` function has been called at least once.
        @ObservationIgnored private(set) var didConfigure = false
        
        /// Creates an empty, unconfigured `Path`.
        ///
        /// This initializer is intended for creating empty, unconfigured `Path`s which are then injected into a ``ManagedNavigationStack``.
        public init() {}
    }
}


// MARK: Configuration & Management

extension ManagedNavigationStack.Path {
    /// ``NavigationStepIdentifier`` of the first view in ``ManagedNavigationStack``.
    /// `nil` if the ``ManagedNavigationStack`` is empty.
    var firstStepIdentifier: NavigationStepIdentifier? {
        steps.elements.first?.key
    }
    
    /// The initial view that is presented to the user.
    ///
    /// In case there isn't a single navigation step stored within ``steps``
    /// (meaning the ``NavigationStack`` contains no steps),
    /// the property serves an `EmptyView` which is then dismissed immediately as the ``isComplete`` property
    /// is automatically set to true.
    var firstStep: AnyView {
        guard let firstStepIdentifier,
              let view = steps[firstStepIdentifier] else {
            return AnyView(EmptyView())
        }
        return AnyView(view)
    }
    
    /// Identifier of the current navigation step that is shown to the user via its associated view.
    private var currentStep: NavigationStepIdentifier? {
        guard let lastElement = path.last(where: { !$0.isCustom }) else {
            return firstStepIdentifier
        }
        return lastElement
    }
    
    /// Updates the path, based on a ``ManagedNavigationStack``'s current content.
    /// - Parameters:
    ///   - elements: The navigation steps that should be placed into the ``ManagedNavigationStack``.
    ///   - isComplete: An optional SwiftUI `Binding` that is injected by the ``ManagedNavigationStack``.
    ///     Is managed by the ``ManagedNavigationStack/Path`` to indicate whether the navigation flow is complete.
    ///   - startStepSelector: Optionally, the step the `Path` should initially move to.
    func configure(
        elements: [ManagedNavigationStack.StepsCollection.Element],
        isComplete: Binding<Bool>?,
        startAtStep startStepSelector: StepSelector?
    ) {
        didConfigure = true
        self.isComplete = isComplete
        updateViews(with: elements)
        // If specified, navigate to the first to-be-shown navigation step
        if let startStepSelector {
            navigateToNextStep(matching: startStepSelector, includeIntermediateSteps: false)
        }
    }
    
    /// Internal function used to update the navigation steps within the `Path` if the
    /// result builder associated with the ``ManagedNavigationStack`` is re-evaluated.
    ///
    /// This may be the case with `async` properties that are stored as a SwiftUI `State` in the respective view.
    ///
    /// - Parameters:
    ///   - elements: The updated navigation steps.
    func updateViews(with elements: [ManagedNavigationStack.StepsCollection.Element]) {
        func failWithConflictingIdentifiers(
            existingIdentifier: NavigationStepIdentifier,
            newIdentifier: NavigationStepIdentifier,
            file: StaticString = #file,
            line: UInt = #line
        ) -> Never {
            preconditionFailure(
                """
                SpeziViews: \(Self.self) contains elements with duplicate navigation step identifiers.
                This is invalid. If your stack contains multiple instances of the same View type,
                use the 'navigationStepIdentifier(_:)' View modifier to uniquely identify it within the stack.
                Problematic identifier: \(newIdentifier).
                Conflicting identifier: \(existingIdentifier)
                """,
                file: file,
                line: line
            )
        }
        do {
            // Ensure that the incoming navigation stack elements are all unique.
            // Note: we don't need to worry about collisions between NavigationFlow-provided
            // views and manually-added custom views, since the non-custom ones will
            // always also be identified by their source location, which is never the case for the custom ones.
            var identifiersSeenSoFar = Set<NavigationStepIdentifier>()
            for element in elements {
                let identifier = NavigationStepIdentifier(element: element)
                guard identifiersSeenSoFar.insert(identifier).inserted else {
                    // SAFETY: we know that there will be a matching element, otherwise the insert above would've succeeded.
                    let conflictingIdentifier = identifiersSeenSoFar.first { $0 == identifier }! // swiftlint:disable:this force_unwrapping
                    failWithConflictingIdentifiers(
                        existingIdentifier: conflictingIdentifier,
                        newIdentifier: identifier
                    )
                }
            }
        }
        // Only allow view updates to views ahead of the current navigation step.
        // Without this limitation, attempts to navigate backwards or dismiss the currently displayed navigation step
        // (for example, after receiving HealthKit authorizations) could lead to unintended behavior.
        // Note: This approach isn't perfect. Imaging we're at step 5 in the ManagedNavigationStack, and some condition in the
        // view changes and we remove step 3 from the NavigationFlow. In this case, we won't actually remove it from the stack,
        // since we're at a later step and removing step 3 while being at step 5 is not a good idea.
        // But now if you return to step 1, and then start going forward again, it still will include step 3.
        // We might want to keep track of such situations, and re-apply the changes when the stack navigates back?
        let currentStepIndex = currentStep.flatMap {
            steps.elements.keys.firstIndex(of: $0)
        } ?? 0
        // Remove all navigation steps after the current navigation step
        let nextStepIndex = currentStepIndex + 1
        if nextStepIndex < steps.elements.endIndex {
            steps.removeSubrange(nextStepIndex...)
        }
        for element in elements {
            let identifier = NavigationStepIdentifier(element: element)
            let stepIsAfterCurrentStep = !steps.keys.contains(identifier)
            guard stepIsAfterCurrentStep else {
                continue
            }
            if let conflictingIdentifier = steps.keys.first(where: { $0 == identifier }) {
                // We need the check again in here, since there might also be collisions between
                // the part of the incoming steps we integrate into the view and the existing,
                // already-visited steps we keep around.
                failWithConflictingIdentifiers(existingIdentifier: conflictingIdentifier, newIdentifier: identifier)
            }
            steps[identifier] = element.view
        }
        updateIsCompleteBinding()
    }
    
    private func updateIsCompleteBinding() {
        if steps.isEmpty && !(isComplete?.wrappedValue ?? false) {
            isComplete?.wrappedValue = true
        }
    }
}


// MARK: Navigation

extension ManagedNavigationStack.Path {
    /// Internal function used to navigate to the respective `View` via the `NavigationStack.navigationDestination(for:)` function,
    /// either regularly declared within the ``ManagedNavigationStack`` or custom steps
    /// passed via ``append(customView:)``, identified by the ``NavigationStepIdentifier``.
    ///
    /// - Parameters:
    ///   - stepIdentifier: The navigation step identified via ``NavigationStepIdentifier``
    /// - Returns: `View` corresponding to the passed ``NavigationStepIdentifier``
    func view(for stepIdentifier: NavigationStepIdentifier) -> AnyView {
        if stepIdentifier.isCustom {
            guard let view = customSteps[stepIdentifier] else {
                return AnyView(IllegalNavigationStepView())
            }
            return AnyView(view)
        }
        guard let view = steps[stepIdentifier] else {
            return AnyView(IllegalNavigationStepView())
        }
        return AnyView(view)
    }
    
    /// Pushes a ``NavigationStepIdentifier`` onto the stack.
    ///
    /// - Invariant: only call this function with ``NavigationStepIdentifier``s that are known to the ``Path``.
    private func pushStep(identifiedBy identifier: NavigationStepIdentifier) {
        path.append(identifier)
    }
    
    /// Moves to the next navigation step.
    ///
    /// An invocation of this function moves the ``Path`` to the
    /// next navigation step as outlined by the order of views within the ``ManagedNavigationStack``.
    ///
    /// The tracking of the current state of the navigation flow is done fully automatic by the ``ManagedNavigationStack/Path``.
    ///
    /// After all navigation steps have been shown, the injected `isComplete` binding is set to `true` indicating that the navigation flow is completed.
    public func nextStep() {
        guard let currentStepIndex = steps.elements.keys.firstIndex(where: { $0 == currentStep }),
              currentStepIndex + 1 < steps.elements.count else {
            isComplete?.wrappedValue = true
            return
        }
        pushStep(identifiedBy: steps.elements.keys[currentStepIndex + 1])
    }
    
    /// Modifies the navigation path to move to the next navigation step identified by the specified value, and also add all steps inbetween.
    ///
    /// This function will look at all navigation steps after the current step, identify the first one that matches `selector`, and push it onto the stack.
    /// Optionally, it will also push all intermediate steps between the current step and the one matching `selector`.
    ///
    /// If no step matching `stepRef` exists, this function will have no effect.
    ///
    /// - parameter selector: The selector used to identify the first matching step.
    /// - parameter includeIntermediateSteps: Whether the stack should include all intermediate steps between the current step and the one matching `id`.
    ///
    /// - Note: If `stepRef` is a `View` type, this function will navigate to the first step (following the current step) with a matching view type,
    ///     even if that step is also using a custom identifier. If there are multiple steps with this type, and you want to select a step other than the first one,
    ///     use an explicit identifier for matching instead.
    public func navigateToNextStep(matching selector: StepSelector, includeIntermediateSteps: Bool) {
        let currentIndex = currentStep.flatMap {
            steps.keys.firstIndex(of: $0)
        } ?? 0
        guard let stepIdentifierIdx = steps.keys[currentIndex...].dropFirst().firstIndex(where: { stepIdentifier in
            guard !stepIdentifier.isCustom else {
                return false
            }
            switch (selector, stepIdentifier.identifierKind) {
            case (.viewType(let type), _):
                return stepIdentifier.stepType == type
            case let (.identifier(valueA), .identifiable(valueB)):
                return valueA.isEqual(valueB)
            case (.identifier, .viewTypeAndSourceLoc):
                return false
            }
        }) else {
            // unable to find matching step; ignore navigation request.
            // this is either because we're trying to navigate to some view that doesn't exist,
            // or because we're trying to push the view that's already the current view
            // (this happens eg if you specify a selector matching the initial view as the startingAt param).
            return
        }
        if includeIntermediateSteps {
            path = Array(steps.keys[...stepIdentifierIdx].dropFirst())
        } else {
            path.append(steps.keys[stepIdentifierIdx])
        }
    }
    
    /// Moves the navigation path to the custom view.
    ///
    /// - Note: The custom `View` does not have to be declared within the ``ManagedNavigationStack``.
    ///     Resulting from that, the internal state of the ``ManagedNavigationStack/Path`` is still referencing to the last regular step.
    ///
    /// - Parameters:
    ///   - customView: A custom `View` instance that should be shown next in the navigation flow.
    ///     It isn't required to declare this view within the ``ManagedNavigationStack``.
    public func append(customView: some View) {
        let customStepIdentifier = NavigationStepIdentifier(
            element: .init(view: customView, sourceLocation: nil)
        )
        customSteps[customStepIdentifier] = customView
        pushStep(identifiedBy: customStepIdentifier)
    }
    
    /// Removes the last element on top of the navigation path.
    ///
    /// This method allows to manually move backwards within the navigation flow.
    public func removeLast() {
        path.removeLast()
    }
}
