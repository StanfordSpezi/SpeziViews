//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A `Identifiable` protocol that is isolated to the MainActor.
///
/// The `id` property of the `Identifiable` protocol a non-isolation requirement we cannot fulfill. Therefore, we need to introduce our own requirement.
@MainActor
protocol NavigationStepIdentifiable {
    associatedtype ID: Hashable

    var id: ID { get }
}


@_documentation(visibility: internal)
public struct _NavigationStepIdentifierViewModifier<ID: Hashable>: ViewModifier, NavigationStepIdentifiable {
    // swiftlint:disable:previous type_name
    let id: ID

    public func body(content: Content) -> some View {
        content
    }
}


extension View {
    /// Assign a unique identifier to a `View` appearing as a step within in a ``ManagedNavigationStack``.
    ///
    /// This allows programmatic navigation to the view using the ``ManagedNavigationStack/Path``'s ``ManagedNavigationStack/Path/navigateToNextStep(matching:includeIntermediateSteps:)`` function.
    /// When applying this modifier repeatedly, the outermost ``SwiftUICore/View/navigationStepIdentifier(_:)`` takes precedence.
    ///
    /// The ``ManagedNavigationStack`` will identify the step based on the combination of the identifier value and the identifier's type.
    ///
    /// - Parameters:
    ///   - id: The `Hashable` value used to identify the view as a step within a ``ManagedNavigationStack``.
    ///
    /// - Note: This is completely separate from SwiftUI's `id(_:)` modifier.
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
    ///         }
    ///     }
    /// }
    /// ```
    public func navigationStepIdentifier<ID: Hashable>(_ id: ID) -> ModifiedContent<Self, _NavigationStepIdentifierViewModifier<ID>> {
        modifier(_NavigationStepIdentifierViewModifier(id: id))
    }
}


extension ModifiedContent: NavigationStepIdentifiable where Modifier: NavigationStepIdentifiable {
    var id: Modifier.ID {
        self.modifier.id
    }
}
