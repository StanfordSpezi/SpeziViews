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
public struct _OnboardingIdentifiableViewModifier<ID>: ViewModifier, NavigationStepIdentifiable where ID: Hashable {
    // swiftlint:disable:previous type_name
    let id: ID

    public func body(content: Content) -> some View {
        content
    }
}


extension View {
    /// Assign a unique identifier to a `View` appearing in an `OnboardingStack`.
    ///
    /// A `ViewModifier` assigning an identifier to the `View` it is applied to.
    /// When applying this modifier repeatedly, the outermost ``SwiftUICore/View/onboardingIdentifier(_:)`` counts.
    ///
    /// - Note: This `ViewModifier` should only be used to identify `View`s of the same type within an ``OnboardingStack``.
    ///
    /// - Parameters:
    ///   - identifier: The `Hashable` identifier given to the view.
    ///
    /// ```swift
    /// struct Onboarding: View {
    ///     @AppStorage(StorageKeys.onboardingFlowComplete)
    ///     var completedOnboardingFlow = false
    ///
    ///     var body: some View {
    ///         OnboardingStack(onboardingFlowComplete: $completedOnboardingFlow) {
    ///             MyOwnView()
    ///                 .onboardingIdentifier("my-own-view-1")
    ///             MyOwnView()
    ///                 .onboardingIdentifier("my-own-view-2")
    ///         }
    ///     }
    /// }
    /// ```
    public func onboardingIdentifier<ID: Hashable>(_ identifier: ID) -> ModifiedContent<Self, _OnboardingIdentifiableViewModifier<ID>> {
        // For some reason, we need to explicitly spell the return type, otherwise the type will be `AnyView`.
        // Not sure how that happens, but it does with Xcode 16 toolchain.
        modifier(_OnboardingIdentifiableViewModifier(id: identifier))
    }
}


extension ModifiedContent: NavigationStepIdentifiable where Modifier: NavigationStepIdentifiable {
    var id: Modifier.ID {
        self.modifier.id
    }
}


private protocol AnyModifiedContent {
    associatedtype _Content
    associatedtype _Modifier
    var content: _Content { get }
    var modifier: _Modifier { get }
}

extension ModifiedContent: AnyModifiedContent {
    typealias _Content = Content
    typealias _Modifier = Modifier
}


extension View {
    var customNavigationStepIdentifier: AnyHashable? {
        guard let self = self as? any AnyModifiedContent else {
            return nil
        }
        fatalError()
    }
}
