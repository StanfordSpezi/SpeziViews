//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//


import OSLog
import SwiftUI


/// Managed Navigation Stack
///
/// The `ManagedNavigationStack` wraps a SwiftUI `NavigationStack`, and provides an API for defining the Stack's individual steps and for navigating between them,
/// eliminating the need for developers to manually determine the next to be shown step within each onboarding view (e.g. skipped steps as permissions are already granted).
/// All of the (conditional) onboarding views are stated within the `ManagedNavigationStack` from which the order of the onboarding flow is determined.
///
/// Navigation within the `ManagedNavigationStack` is possible via the ``ManagedNavigationStack/Path`` which works similar to SwiftUI's `NavigationPath`.
/// The ``ManagedNavigationStack/Path``'s ``ManagedNavigationStack/Path/nextStep()``, ``ManagedNavigationStack/Path/appendStep(_:)-1ndu9``,
/// and ``ManagedNavigationStack/Path/moveToNextStep(ofType:)`` functions can be used to programmatically navigate within the stack.
/// Furthermore, one can append custom onboarding steps that are not declared within the  `ManagedNavigationStack`
/// (e.g. as the structure of these steps isn't linear) via ``ManagedNavigationStack/Path/append(customView:)``.
/// See the ``ManagedNavigationStack/Path`` for more details.
///
/// The ``ManagedNavigationStack/Path`` is injected as an `Observable` into the environment of the `ManagedNavigationStack` view hierarchy.
/// Resulting from that, all views declared within the `ManagedNavigationStack` are able to access a single instance of the ``ManagedNavigationStack/Path``.
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
///     @State private var localNotificationAuthorization = false
///
///     var body: some View {
///         ManagedNavigationStack(onboardingFlowComplete: $completedOnboardingFlow) {
///             Welcome()
///             InterestingModules()
///
///             if HKHealthStore.isHealthDataAvailable() {
///                 HealthKitPermissions()
///             }
///
///             if !localNotificationAuthorization {
///                 NotificationPermissions()
///             }
///         }
///         .task {
///             localNotificationAuthorization = await ...
///         }
///     }
/// }
/// ```
///
/// ### Identifying Onboarding Views
///
/// Apply the ``SwiftUICore/View/onboardingIdentifier(_:)`` modifier to clearly identify a view in the `ManagedNavigationStack`.
/// This is particularly useful in scenarios where multiple instances of the same view type might appear in the stack.
///
/// ```swift
/// struct Onboarding: View {
///     @AppStorage(StorageKeys.onboardingFlowComplete) var completedOnboardingFlow = false
///
///     var body: some View {
///         ManagedNavigationStack(onboardingFlowComplete: $completedOnboardingFlow) {
///             MyOwnView()
///                 .onboardingIdentifier("my-own-view-1")
///             MyOwnView()
///                 .onboardingIdentifier("my-own-view-2")
///             // Other views as needed
///         }
///     }
/// }
/// ```
///
/// - Note: When the ``SwiftUICore/View/onboardingIdentifier(_:)`` modifier is applied multiple times to the same view, the outermost identifier takes precedence.
///
/// ## Topics
/// ### Creating an Onboarding Stack
/// - ``init(onboardingFlowComplete:path:startAtStep:_:)-3fn08``
/// - ``init(onboardingFlowComplete:path:startAtStep:_:)-39lmr``
/// - ``OnboardingFlowBuilder``
/// ### SwiftUI Environment Values
/// - ``SwiftUICore/EnvironmentValues/isInOnboardingStack``
public struct ManagedNavigationStack/*<Content: View>*/: View {
    public typealias Path = ManagedNavigationStackPath
    static let logger = Logger(subsystem: "edu.stanford.spezi.SpeziViews", category: "ManagedNavigationStack")
    
    private let onboardingFlow: _NavigationFlow
    private let isComplete: Binding<Bool>?
    private let startAtStep: Path.StepReference?
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
            path.firstOnboardingView
                .padding(.top, 24)
                .environment(\.isInManagedNavigationStack, true)
                //.environment(\.isFirstInManagedNavigationStack, true)
                .navigationDestination(for: NavigationStepIdentifier.self) { step in
                    path.view(for: step)
                        .environment(\.isInManagedNavigationStack, true)
                }
        }
        .environment(path)
        .onChange(of: ObjectIdentifier(onboardingFlow)) {
            // ensure the model uses the latest views from the initializer
            path.updateViews(with: onboardingFlow.elements)
        }
    }
    
    private init(
        onboardingFlowComplete: Binding<Bool>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        path externalPath: Path? = nil, // swiftlint:disable:this function_default_parameter_at_end
        startAtStep: Path.StepReference?,
        @NavigationFlowBuilder _ content: @MainActor () -> _NavigationFlow
    ) {
        onboardingFlow = content()
        isComplete = onboardingFlowComplete
        self.externalPath = externalPath
        self.startAtStep = startAtStep
        if !path.didConfigure {
            // Note: we intentionally perform the initial configuration in here, instead of in the init.
            // The reason for this is that calling path.configure in the init will, for some reason, cause
            // a neverending loop of view updates when using an external path. Calling it in here does not.
            configurePath()
        }
    }
    
    /// A `ManagedNavigationStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``ManagedNavigationStack/Path`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `ManagedNavigationStack`.
    ///   - externalPath: An optional, externally-managed ``ManagedNavigationStack/Path`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the ``OnboardingFlowBuilder``.
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil,
        path externalPath: Path? = nil,
        startAtStep: (any View.Type)? = nil,
        @NavigationFlowBuilder _ content: @MainActor () -> _NavigationFlow
    ) {
        self.init(
            onboardingFlowComplete: onboardingFlowComplete,
            path: externalPath,
            startAtStep: startAtStep.map { .viewType($0) },
            content
        )
    }
    
    /// A `ManagedNavigationStack` is defined by the passed in views defined by the view builder as well as an boolean `Binding`
    /// that is set to true when the onboarding flow is completed.
    /// - Parameters:
    ///   - onboardingFlowComplete: An optional SwiftUI `Binding` that is automatically set to true by
    ///     the ``ManagedNavigationStack/Path`` once the onboarding flow is completed.
    ///     Can be used to conditionally show/hide the `ManagedNavigationStack`.
    ///   - externalPath: An optional, externally-managed ``ManagedNavigationStack/Path`` which will be used by this view.
    ///       Only specify this if you actually need external control over the path; otherwise omit it to get the recommended default behaviour.
    ///   - startAtStep: An optional SwiftUI (Onboarding) `View` type indicating the first to-be-shown step of the onboarding flow.
    ///   - content: The SwiftUI (Onboarding) `View`s that are part of the onboarding flow.
    ///     You can define the `View`s using the ``OnboardingFlowBuilder``.
    public init(
        onboardingFlowComplete: Binding<Bool>? = nil, // swiftlint:disable:this function_default_parameter_at_end
        path externalPath: Path? = nil, // swiftlint:disable:this function_default_parameter_at_end
        startAtStep: (any Hashable)?,
        @NavigationFlowBuilder _ content: @MainActor () -> _NavigationFlow
    ) {
        self.init(
            onboardingFlowComplete: onboardingFlowComplete,
            path: externalPath,
            startAtStep: startAtStep.map { .identifier($0) },
            content
        )
    }
    
    private func configurePath() {
        path.configure(elements: onboardingFlow.elements, isComplete: isComplete, startAtStep: startAtStep)
    }
}


extension EnvironmentValues {
    /// Whether the view is currently contained within an ``ManagedNavigationStack``.
    ///
    /// - Note: Don't set this value manually; ``ManagedNavigationStack`` will set it for you where applicable.
    @Entry public var isInManagedNavigationStack: Bool = false
    
    /// Whether the view is the first view contained within an ``ManagedNavigationStack``.
    ///
    /// - Note: Don't set this value manually; ``ManagedNavigationStack`` will set it for you where applicable.
    @Entry public var isFirstInManagedNavigationStack: Bool = false
}


#if DEBUG
#Preview {
    @Previewable @State var path = ManagedNavigationStack.Path()
    
    ManagedNavigationStack(path: path, startAtStep: 1) {
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("First Step")
        .onboardingIdentifier(0)
        Button("Next") {
            path.nextStep()
        }
        .navigationTitle("Second Step")
        .onboardingIdentifier(1)
    }
}
#endif
