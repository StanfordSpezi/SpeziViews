//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import OSLog
import SwiftUI


/// Managed Navigation Stack with programmatic control over navigation within the stack.
///
/// The `ManagedNavigationStack` wraps a SwiftUI `NavigationStack`, providing APIs for defining the stack's individual steps and for navigating between them.
/// This allows for efficient and easy-to-use `NavigationStack`-based view setups with potentially-dynamic content or non-linear navigation rules,
/// eliminating the need for developers to manually determine the next to be shown step within each view
/// (e.g.: as part of an onboarding view, you might want to skip the step asking the user for push notification permissions, if this has already been granted).
/// All of the (conditional) navigation step views are declared within the `ManagedNavigationStack` from which the order of the navigation flow is determined.
///
/// Programmatic navigation within the `ManagedNavigationStack` is possible via the ``ManagedNavigationStack/Path`` which works similar to SwiftUI's `NavigationPath`.
/// The ``ManagedNavigationStack/Path``'s ``ManagedNavigationStack/Path/nextStep()`` and ``ManagedNavigationStack/Path/navigateToNextStep(matching:includeIntermediateSteps:)``,
/// functions can be used to programmatically navigate within the stack.
/// Furthermore, one can dynamically append custom navigation steps that are not declared within the  ``ManagedNavigationStack``
/// (e.g. as the structure of these steps isn't linear) via ``ManagedNavigationStack/Path/append(customView:)``.
/// See the ``ManagedNavigationStack/Path`` for more details.
///
/// The ``ManagedNavigationStack/Path`` is injected as an environment object into the environment of the ``ManagedNavigationStack`` view hierarchy,
/// allowing the individual navigation steps to access and control their containing ``ManagedNavigationStack``'s navigation.
///
/// Example: Building a managed onboarding stack
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage("didCompleteOnboarding") var didCompleteOnboarding = false
///     @State private var localNotificationAuthorization = false
///
///     var body: some View {
///         ManagedNavigationStack(didComplete: $didCompleteOnboarding) {
///             Welcome()
///             InterestingModules()
///             if HKHealthStore.isHealthDataAvailable() {
///                 HealthKitPermissions()
///             }
///             if !localNotificationAuthorization {
///                 NotificationPermissions()
///             }
///             FinalStep()
///         }
///         .task {
///             localNotificationAuthorization = await ...
///         }
///     }
/// }
/// ```
///
/// ### Identifying Navigation Steps
///
/// By default, the ``ManagedNavigationStack`` will identify and track the different navigation steps based on their type and location within the stack.
/// The ``SwiftUICore/View/navigationStepIdentifier(_:)`` modifier allows overriding the default identifier
/// with a custom one that will be used instead throughout the ``ManagedNavigationStack``.
/// In most scenarios, the default identifier is sufficient, but there are some edge cases where a custom identifier needs to be specified,
/// namely when the ``ManagedNavigationStack`` contains multiple steps with the same `View` type, and you wish to programmatically
/// navigate to one of them, be it as the stack's starting step (via the `startAtStep` parameter in ``ManagedNavigationStack/init(didComplete:path:startAtStep:_:)``,
/// or via e.g. ``ManagedNavigationStack/Path/navigateToNextStep(matching:includeIntermediateSteps:)``.
///
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage(StorageKeys.onboardingFlowComplete)
///     var completedOnboardingFlow = false
///
///     var body: some View {
///         ManagedNavigationStack(didComplete: $completedOnboardingFlow) {
///             MyOwnView()
///                 .navigationStepIdentifier("step1")
///             MyOwnView()
///                 .navigationStepIdentifier("step2")
///             // Other views as needed
///         }
///     }
/// }
/// ```
///
/// - Note: When the ``SwiftUICore/View/navigationStepIdentifier(_:)`` modifier is applied multiple times to the same view, the outermost identifier takes precedence.
///
/// ## Topics
/// ### Creating a Managed Navigation Stack
/// - ``init(didComplete:path:startAtStep:_:)``
/// - ``StepsBuilder``
/// ### Navigation
/// - ``Path``
/// ### SwiftUI Environment Values
/// - ``SwiftUICore/EnvironmentValues/isInManagedNavigationStack``
/// - ``SwiftUICore/EnvironmentValues/isFirstInManagedNavigationStack``
public struct ManagedNavigationStack: View {
    static var logger: Logger { Logger(subsystem: "edu.stanford.spezi.SpeziViews", category: "ManagedNavigationStack") }
    
    private let steps: StepsCollection
    private let isComplete: Binding<Bool>?
    private let startStepSelector: Path.StepSelector?
    private var externalPath: Path?
    @State private var internalPath = Path()
    
    /// The effective ``ManagedNavigationStack/Path``
    var path: Path {
        externalPath ?? internalPath
    }
    
    @_documentation(visibility: internal)
    public var body: some View {
        @Bindable var path = path
        NavigationStack(path: $path.path) {
            path.firstStep
                .environment(\.isFirstInManagedNavigationStack, true)
                .navigationDestination(for: NavigationStepIdentifier.self) { step in
                    path.view(for: step)
                }
        }
        .environment(path)
        .environment(\.isInManagedNavigationStack, true)
        .onChange(of: ObjectIdentifier(steps)) {
            // ensure the model uses the latest views from the initializer
            path.updateViews(with: steps.elements)
        }
    }
    
    /// Creates a new Managed Navigation Stack.
    ///
    ///
    /// A ``ManagedNavigationStack`` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the navogation stack reaches .
    /// - Parameters:
    ///   - didComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``ManagedNavigationStack/Path`` once the flow is completed.
    ///     Can be used to conditionally show/hide the ``ManagedNavigationStack``.
    ///   - externalPath: An optional, externally-managed ``ManagedNavigationStack/Path`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startStepSelector: An optional reference to a step the managed navigation stack should implicitly move to as its starting position.
    ///   - content: The SwiftUI `View`s that are part of the navigation flow. Each `View` included here will become its own navigation step in the ``ManagedNavigationStack``.
    public init(
        didComplete: Binding<Bool>? = nil,
        path externalPath: Path? = nil,
        startAtStep startStepSelector: Path.StepSelector? = nil,
        @StepsBuilder _ content: @MainActor () -> StepsCollection
    ) {
        steps = content()
        isComplete = didComplete
        self.externalPath = externalPath
        self.startStepSelector = startStepSelector
        if !path.didConfigure {
            // Note: we intentionally perform the initial configuration in here, instead of in the init.
            // The reason for this is that calling path.configure in the init will, for some reason, cause
            // a neverending loop of view updates when using an external path. Calling it in here does not.
            configurePath()
        }
    }
    
    private func configurePath() {
        path.configure(elements: steps.elements, isComplete: isComplete, startAtStep: startStepSelector)
    }
}


extension EnvironmentValues {
    /// Whether the view is currently contained within a ``ManagedNavigationStack``.
    ///
    /// - Note: You don't set this value manually; ``ManagedNavigationStack`` will set it for you where applicable.
    @Entry public var isInManagedNavigationStack: Bool = false
    
    /// Whether the view is the first view contained within a ``ManagedNavigationStack``.
    ///
    /// - Note: You don't set this value manually; ``ManagedNavigationStack`` will set it for you where applicable.
    @Entry public var isFirstInManagedNavigationStack: Bool = false
}


#if DEBUG
#Preview {
    @Previewable @State var path = ManagedNavigationStack.Path()
    
    ManagedNavigationStack(path: path, startAtStep: .identifier(1)) {
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("First Step")
        .navigationStepIdentifier(0)
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("Second Step")
        .navigationStepIdentifier(1)
    }
}
#endif
