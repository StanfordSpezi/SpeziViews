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
/// (i.e., was not included in the ``ManagedNavigationStack``'s contents, but rather programmatically pushed onto the stack using ``ManagedNavigationStack/Path/append(customView:)``).
struct NavigationStepIdentifier {
    /// The source of the `NavigationStepIdentifier`'s identity
    enum IdentifierKind {
        /// The `NavigationStepIdentifier` derives its identity from a `View`'s type and source location
        case viewTypeAndSourceLoc
        /// The `NavigationStepIdentifier` derives its identity from a `Hashable` value.
        case identifiable(any Hashable)
    }
    
    let identifierKind: IdentifierKind
    let viewType: any View.Type
    let flowElementSourceLocation: _NavigationFlow.Element.SourceLocation?
    
    /// Whether the step is custom, i.e. not one of the steps defined via the ``NavigationFlowBuilder`` but instead created via e.g. ``ManagedNavigationStack/Path/append(customView:)``.
    var isCustom: Bool {
        flowElementSourceLocation == nil
    }
    
    /// Initializes an identifier using a view. If the view conforms to `Identifiable`, its `id` is used; otherwise, the view's type is used.
    /// - Parameters:
    ///   - view: The view used to initialize the identifier.
    ///   - custom: A flag indicating whether the step is custom.
    @MainActor
    init(element: _NavigationFlow.Element) {
        self.viewType = type(of: element.view)
        self.flowElementSourceLocation = element.sourceLocation
        if let identifiable = element.view as? any NavigationStepIdentifiable {
            let id = identifiable.id
            self.identifierKind = .identifiable(id)
        } else if let identifiable = element.view as? any Identifiable {
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
            lhs.viewType == rhs.viewType && lhs.flowElementSourceLocation == rhs.flowElementSourceLocation
        case let (.identifiable(lhsValue), .identifiable(rhsValue)):
            lhsValue.isEqual(rhsValue)
        case (.viewTypeAndSourceLoc, .identifiable), (.identifiable, .viewTypeAndSourceLoc):
            false
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch self.identifierKind {
        case .viewTypeAndSourceLoc:
            hasher.combine(ObjectIdentifier(viewType))
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
        var desc = "\(Self.self)(isCustom: \(isCustom), viewType: \(viewType), identifierKind: \(identifierKind)"
        if let sourceLoc = flowElementSourceLocation {
            desc += ", sourceLoc: \(sourceLoc.fileId);\(sourceLoc.line);\(sourceLoc.column)"
        }
        desc += ")"
        return desc
    }
}


extension Equatable {
    func isEqual(_ other: any Equatable) -> Bool {
        if let other = other as? Self {
            other == self
        } else {
            false
        }
    }
}
