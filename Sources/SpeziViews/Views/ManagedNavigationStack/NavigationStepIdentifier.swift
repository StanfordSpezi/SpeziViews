//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SwiftUI


/// An `NavigationStepIdentifier` serves as an abstraction of a step in the navigation flow as outlined within the ``ManagedNavigationStack``.
///
/// It contains both the identifier for a navigation step (the view's type) as well as a flag that indicates if whether the step is custom
/// (i.e., was not included in the ``ManagedNavigationStack``'s contents, but rather programmatically pushed onto the stack using ``ManagedNavigationStack/Path/append(_:)``).
struct NavigationStepIdentifier {
    /// The source of the `NavigationStepIdentifier`'s identity
    enum IdentifierKind: Equatable {
        /// The `NavigationStepIdentifier` derives its identity from a `View`'s type and source location
        case viewTypeAndSourceLoc
        /// The `NavigationStepIdentifier` derives its identity from a `Hashable` value.
        case identifiable(any Hashable)
        
        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case (.viewTypeAndSourceLoc, .viewTypeAndSourceLoc):
                true
            case let (.identifiable(lhsValue), .identifiable(rhsValue)):
                lhsValue.isEqual(to: rhsValue)
            case (.viewTypeAndSourceLoc, .identifiable), (.identifiable, .viewTypeAndSourceLoc):
                false
            }
        }
    }
    
    let identifierKind: IdentifierKind
    /// The type of the navigation step.
    ///
    /// This is the "full type" of the step as collected by the ``ManagedNavigationStack/StepsBuilder``.
    /// For navigation steps that are `View`s with modifiers applied to them, this will be the type including the modifier stack.
    let stepType: any View.Type
    let flowElementSourceLocation: ManagedNavigationStack.StepsCollection.Element.SourceLocation?
    
    /// Whether the step is custom, i.e. not one of the steps defined via the ``NavigationFlowBuilder`` but instead created via e.g. ``ManagedNavigationStack/Path/append(_:)``.
    var isCustom: Bool {
        flowElementSourceLocation == nil
    }
    
    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - parameter element: The ``ManagedNavigationStack/StepsCollection/Element`` for which we want to create an identifier
    @MainActor
    init(element: ManagedNavigationStack.StepsCollection.Element) {
        let view = element.view
        self.stepType = type(of: view)
        self.flowElementSourceLocation = element.sourceLocation
        if let identifiable = view as? any NavigationStepIdentifiable {
            let id = identifiable.id
            self.identifierKind = .identifiable(id)
        } else if let identifiable = view as? any Identifiable {
            let id = identifiable.id
            self.identifierKind = .identifiable(id)
        } else {
            self.identifierKind = .viewTypeAndSourceLoc
        }
    }
}


extension NavigationStepIdentifier: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs.identifierKind, rhs.identifierKind) {
        case (.viewTypeAndSourceLoc, .viewTypeAndSourceLoc):
            lhs.stepType == rhs.stepType && lhs.flowElementSourceLocation == rhs.flowElementSourceLocation
        case let (.identifiable(lhsValue), .identifiable(rhsValue)):
            lhsValue.isEqual(to: rhsValue)
        case (.viewTypeAndSourceLoc, .identifiable), (.identifiable, .viewTypeAndSourceLoc):
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self.identifierKind {
        case .viewTypeAndSourceLoc:
            hasher.combine(ObjectIdentifier(stepType))
            if let flowElementSourceLocation {
                hasher.combine(flowElementSourceLocation)
            }
        case .identifiable(let value):
            hasher.combine(ObjectIdentifier(type(of: value)))
            hasher.combine(value)
        }
    }
}


extension NavigationStepIdentifier: CustomDebugStringConvertible {
    var debugDescription: String {
        var desc = "\(Self.self)(isCustom: \(isCustom), stepType: \(stepType), identifierKind: \(identifierKind)"
        if let sourceLoc = flowElementSourceLocation {
            desc += ", sourceLoc: \(sourceLoc.fileId);\(sourceLoc.line);\(sourceLoc.column)"
        }
        desc += ")"
        return desc
    }
}


extension Equatable {
    @inlinable
    func isEqual(to other: Any) -> Bool {
        if let other = other as? Self {
            other == self
        } else {
            false
        }
    }
}
