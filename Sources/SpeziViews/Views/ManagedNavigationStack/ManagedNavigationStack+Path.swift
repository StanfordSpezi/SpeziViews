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



/// Describes the current navigation state of a ``ManagedNavigationStack``.
///
/// The `Path` wraps SwiftUI's `NavigationPath` and tailors it for the use within the ``ManagedNavigationStack``
/// which provides an easy-to-use interface for creating Onboarding Flows within health applications.
///
/// At the core of the ``ManagedNavigationStack/Path`` stands a wrapped `NavigationPath` from SwiftUI.
/// Based on the onboarding views and conditions defined within the ``ManagedNavigationStack``, the ``ManagedNavigationStack/Path``
/// enables developers to easily navigate through the onboarding procedure
/// without repeated condition checking in every single onboarding view.
///
/// The ``ManagedNavigationStack/Path`` is injected as an `Observable` into the Environment of the ``ManagedNavigationStack`` view hierarchy.
/// Resulting from that, all views declared within the ``ManagedNavigationStack`` are able to access a single instance of the ``ManagedNavigationStack/Path``.
///
/// ```swift
/// struct Welcome: View {
///     @Environment(ManagedNavigationStack.Path.self) private var path
///
///     var body: some View {
///         OnboardingView(
///             ...,
///             action: {
///                 // Navigates to the next onboarding step, as defined in `ManagedNavigationStack` closure.
///                 path.nextStep()
///
///                 // Navigates to the next onboarding step that matches the provided view type.
///                 path.append(InterestingModules.self)
///
///                 // Navigate to a manually injected view. The `ManagedNavigationStack.Path` won't be moved and stay at the old position.
///                 path.append(customView: SomeCustomView())
///             }
///         )
///     }
/// }
/// ```
///
/// ## Topics
/// - ``init()``
/// ### Navigating
/// - ``nextStep()``
/// - ``appendStep(_:)-1ndu9``
/// - ``appendStep(_:)-6x3z0``
/// - ``moveToNextStep(ofType:)``
/// - ``moveToNextStep(withIdentifier:)``
/// - ``removeLast()``
@MainActor
@Observable
public class ManagedNavigationStackPath {
    enum StepReference {
        case viewType(any View.Type)
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

    /// Stores all onboarding views as declared within the ``ManagedNavigationStack`` and keep them in order.
    private var steps: OrderedDictionary<NavigationStepIdentifier, any View> = [:]
    /// Stores all custom onboarding views that are appended to the ``ManagedNavigationStack/Path``
    /// via the ``append(customView:)``  instance methods
    private var customSteps: [NavigationStepIdentifier: any View] = [:]
    /// Indicates whether the Path's ``ManagedNavigationStack/Path/configure`` function has been called at least once.
    private(set) var didConfigure = false


    /// ``OnboardingStepIdentifier`` of first view in ``ManagedNavigationStack``.
    /// `nil` if the ``ManagedNavigationStack`` is empty.
    internal var firstStepIdentifier: NavigationStepIdentifier? {
        steps.elements.first?.key
    }

    /// The initial view that is presented to the user.
    ///
    /// The first onboarding view of the ``steps``.
    ///
    /// In case there isn't a single onboarding view stored within ``steps``
    /// (meaning the ``NavigationStack`` contains no views after its evaluation),
    /// the property serves an `EmptyView` which is then dismissed immediately as the ``isComplete`` property
    /// is automatically set to true.
    var firstOnboardingView: AnyView {
        guard let firstStepIdentifier,
              let view = steps[firstStepIdentifier] else {
            return .init(EmptyView())
        }
        return .init(view)
    }

    /// Identifier of the current onboarding step that is shown to the user via its associated view.
    ///
    /// Inspects the ``path`` to determine the current on-top navigation element of the internal SwiftUI `NavigationPath`.
    /// Utilizes the extension of the `NavigationPath` declared within the ``SpeziOnboarding`` package for this functionality.
    ///
    /// In case there isn't a suitable element within the ``path``, return the `OnboardingStepIdentifier`
    /// of the first onboarding view.
    private var currentOnboardingStep: NavigationStepIdentifier? {
        guard let lastElement = path.last(where: { !$0.isCustom }) else {
            return firstStepIdentifier
        }
        return lastElement
    }
    
    /// Creates an empty, unconfigured `Path`.
    ///
    /// This initializer is intended for creating empty, unconfigured `Path`s which are then injected into an ``ManagedNavigationStack``.
    public init() {}
    
    
    /// An `OnboardingNavigationPath` represents the current navigation path within the ``ManagedNavigationStack``. // TODO better text!
    /// - Parameters:
    ///   - views: SwiftUI `View`s that are declared within the ``ManagedNavigationStack``.
    ///   - isComplete: An optional SwiftUI `Binding` that is injected by the ``ManagedNavigationStack``.
    ///     Is managed by the ``ManagedNavigationStack/Path`` to indicate whether the onboarding flow is complete.
    ///   - startAtStep: Optionally, the step the `Path` should initially move to.
    func configure(elements: [_NavigationFlow.Element], isComplete: Binding<Bool>?, startAtStep: StepReference?) {
        didConfigure = true
        self.isComplete = isComplete
        updateViews(with: elements)
        // If specified, navigate to the first to-be-shown onboarding step
        switch startAtStep {
        case nil:
            break
        case .viewType(let viewType):
            appendStep(viewType)
        case .identifier(let hashable):
            appendStep(hashable)
        }
    }
    
    
    /// Internal function used to update the onboarding steps within the `Path` if the
    /// result builder associated with the ``ManagedNavigationStack`` is reevaluated.
    ///
    /// This may be the case with `async` properties that are stored as a SwiftUI `State` in the respective view.
    ///
    /// - Parameters:
    ///   - views: The updated `View`s from the ``ManagedNavigationStack``.
    func updateViews(with elements: [_NavigationFlow.Element]) {
        do {
            // Ensure that the incoming navigation stack elements are all unique.
            // Note: we don't need to worry about collisions between OnboardingFlow-provided
            // views and manually-added custom views, since the non-custom ones will
            // always also be identified by their source location, which is never the case for the custom ones.
            var identifiersSeenSoFar = Set<NavigationStepIdentifier>()
            for element in elements {
                let identifier = NavigationStepIdentifier(element: element)
                guard identifiersSeenSoFar.insert(identifier).inserted else {
                    let conflictingIdentifier = identifiersSeenSoFar.first(where: { $0 == identifier })
                    preconditionFailure("""
                        SpeziOnboarding: \(Self.self) contains elements with duplicate onboarding step identifiers.
                        This is invalid. If your Stack contains multiple instances of the same View type,
                        use the 'onboardingIdentifier(_:)' View modifier to uniquely identify it within the Stack.
                        Problematic identifier: \(identifier).
                        Conflicting identifier: \(conflictingIdentifier as Any)
                        """)
                }
            }
        }
        // Only allow view updates to views ahead of the current onboarding step.
        // Without this limitation, attempts to navigate backwards or dismiss the currently displayed onboarding step
        // (for example, after receiving HealthKit authorizations) could lead to unintended behavior.
        // Note: This approach isn't perfect. Imaging we're at step 5 in the ManagedNavigationStack, and some condition in the
        // view changes and we remove step 3 from the OnboardingFlow. In this case, we won't actually remove it from the Stack,
        // since we're at a later step and removing step 3 while being at step 5 is not a good idea.
        // But now if you return to step 1, and then start going forward again, it still will include step 3.
        // We might want to keep track of such situations, and re-apply the changes when the Stack navigates back?
        let currentStepIndex = currentOnboardingStep.flatMap {
            steps.elements.keys.firstIndex(of: $0)
        } ?? 0
        // Remove all onboarding steps after the current onboarding step
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
                preconditionFailure("""
                    SpeziOnboarding: \(Self.self) contains elements with duplicate onboarding step identifiers.
                    This is invalid. If your Stack contains multiple instances of the same View type,
                    use the 'onboardingIdentifier(_:)' View modifier to uniquely identify it within the Stack.
                    Problematic identifier: \(identifier).
                    Conflicting identifier: \(conflictingIdentifier)
                    """)
            }
            steps[identifier] = element.view
        }
        onboardingComplete()
    }
    
    
    private func onboardingComplete() {
        if self.steps.isEmpty && !(self.isComplete?.wrappedValue ?? false) {
            self.isComplete?.wrappedValue = true
        }
    }
}


// MARK: Navigation

extension ManagedNavigationStackPath {
    /// Internal function used to navigate to the respective onboarding `View` via the `NavigationStack.navigationDestination(for:)`,
    /// either regularly declared within the ``ManagedNavigationStack`` or custom steps
    /// passed via ``append(customView:)``, identified by the `OnboardingStepIdentifier`.
    ///
    /// - Parameters:
    ///   - stepIdentifier: The onboarding step identified via `OnboardingStepIdentifier`
    /// - Returns: `View` corresponding to the passed `OnboardingStepIdentifier`
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
    
    /// Pushes an ``OnboardingStepIdentifier`` onto the stack.
    private func pushStep(identifiedBy identifier: NavigationStepIdentifier) {
        path.append(identifier)
    }
    
    /// Moves to the next onboarding step.
    ///
    /// An invocation of this function moves the `Path` to the
    /// next onboarding step as outlined by the order of views within the ``ManagedNavigationStack``.
    ///
    /// The tracking of the current state of the onboarding flow is done fully automatic by the ``ManagedNavigationStack/Path``.
    ///
    /// After all onboarding steps have been shown, the injected `complete` `Binding` is set to true indicating that the onboarding flow is completed.
    public func nextStep() {
        guard let currentStepIndex = steps.elements.keys.firstIndex(where: { $0 == currentOnboardingStep }),
              currentStepIndex + 1 < steps.elements.count else {
            isComplete?.wrappedValue = true
            return
        }
        pushStep(identifiedBy: steps.elements.keys[currentStepIndex + 1])
    }
    
    /// Move the path.
    @_documentation(visibility: internal)
    @available(*, deprecated, renamed: "appendStep(_:)")
    public func append(_ stepType: any View.Type) {
        appendStep(stepType)
    }
    
    /// Moves the navigation path to the first onboarding step with a view matching the specified type.
    ///
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    ///
    /// - Important: The specified parameter type must correspond to a `View` type declared within the ``ManagedNavigationStack``. Otherwise, this function will have no effect.
    ///
    /// - Note: When using this function to append a step, any intermediate steps between the current step and the step being moved to will be skipped, and won't be added to the navigation path.
    ///     Use ``moveToNextStep(ofType:)`` instead if you want intermediate steps to be included.
    ///
    /// - Parameters:
    ///   - onboardingStepType: The type of the onboarding `View` which should be displayed next. Must be declared within the ``ManagedNavigationStack``.
    public func appendStep(_ stepType: any View.Type) {
        moveToNextStep(identifiedBy: .viewType(stepType), includeIntermediateSteps: false)
    }
    
    /// Moves the navigation path to the first onboarding step matching the identifier `id`.
    ///
    /// This action integrates seamlessly with the ``nextStep()`` function, meaning one can switch between the ``append(_:)`` and ``nextStep()`` function.
    ///
    /// - Important: The specified parameter type must correspond to a `View` type declared within the ``ManagedNavigationStack``. Otherwise, this function will have no effect.
    ///
    /// - Note: When using this function to append a step, any intermediate steps between the current step and the step being moved to will be skipped, and won't be added to the navigation path.
    ///     Use ``moveToNextStep(withIdentifier:)`` instead if you want intermediate steps to be included.
    ///
    /// - Parameters:
    ///   - id: The identifier of the onboarding step to move to.
    public func appendStep(_ id: some Hashable) {
        moveToNextStep(identifiedBy: .identifier(id), includeIntermediateSteps: false)
    }
    
    /// Modifies the navigation path to move to the first onboarding step of the specified type, and also add all steps inbetween.
    public func moveToNextStep(ofType type: any View.Type) {
        moveToNextStep(identifiedBy: .viewType(type), includeIntermediateSteps: true)
    }
    
    /// Modifies the navigation path to move to the first onboarding step identified by the specified value, and also add all steps inbetween.
    public func moveToNextStep(withIdentifier id: some Hashable) {
        moveToNextStep(identifiedBy: .identifier(id), includeIntermediateSteps: true)
    }
    
    /// Modifies the navigation path to move to the next onboarding step identified by the specified value, and also add all steps inbetween.
    ///
    /// This function will look at all onboarding steps after the current step, identify the first one that matches `stepRef`,
    /// and push all steps between the current step and that step onto the stack (including, of course, the step matching `stepRef`).
    ///
    /// If no step matching `stepRef` exists, this function will have no effect.
    ///
    /// - Note: If `stepRef` is a `View` type, this function will navigate to the first step (following the current step) with a matching view type,
    ///     even if that step is also using a custom identifier. If there are multiple steps with this type, and you want to select a step other than the first one,
    ///     use an explicit identifier for matching instead.
    private func moveToNextStep(identifiedBy stepRef: StepReference, includeIntermediateSteps: Bool) {
        let currentOnboardingIndex = currentOnboardingStep.flatMap {
            steps.keys.firstIndex(of: $0)
        } ?? 0
        guard let stepIdentifierIdx = steps.keys[currentOnboardingIndex...].firstIndex(where: { stepIdentifier in
            guard !stepIdentifier.isCustom else {
                return false
            }
            switch (stepRef, stepIdentifier.identifierKind) {
            case (.viewType(let type), _):
                return stepIdentifier.viewType == type
            case let (.identifier(valueA), .identifiable(valueB)):
                return valueA.isEqual(valueB)
            case (.identifier, .viewTypeAndSourceLoc):
                return false
            }
        }) else {
            ManagedNavigationStack.logger.error("Unable to find step with identifier '\(String(describing: stepRef))'")
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
    ///     Resulting from that, the internal state of the ``ManagedNavigationStack/Path`` is still referencing to the last regular `OnboardingStep`.
    ///
    /// - Parameters:
    ///   - customView: A custom onboarding `View` instance that should be shown next in the onboarding flow.
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
    /// This method allows to manually move backwards within the onboarding navigation flow.
    public func removeLast() {
        path.removeLast()
    }
}
