//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


/// A type-safe wrapper around `UserDefaults`.
///
/// ## Topics
///
/// ### Static Properties
/// - ``standard``
///
/// ### Initializers
/// - ``init(defaults:)``
///
/// ### Accessing Data
/// - ``subscript(_:)->T``
/// - ``subscript(_:)->T?``
/// - ``hasEntry(for:)-(LocalPreferenceKey<Any>.Key)``
/// - ``hasEntry(for:)-(LocalPreferenceKey<Any>)``
/// - ``removeEntry(for:)-(LocalPreferenceKey<Any>.Key)``
/// - ``removeEntry(for:)-(LocalPreferenceKey<Any>)``
///
/// ### Migrations
/// - ``runMigrations(_:)``
/// - ``MigrateName``
/// - ``MigrateValue``
/// - ``Migration``
public struct LocalPreferencesStore: Hashable, @unchecked Sendable {
    /// The Local Preferences Store for `UserDefaults.standard`
    public static let standard = LocalPreferencesStore(defaults: .standard)
    
    @usableFromInline let defaults: UserDefaults
    
    /// Creates a Preferences Store for the specified `UserDefaults` suite.
    @inlinable
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
}


// MARK: Operations

extension LocalPreferencesStore {
    /// Checks whether the store contains an entry for the specified key.
    @inlinable
    public func hasEntry(for key: LocalPreferenceKey<some Any>) -> Bool {
        hasEntry(for: key.key)
    }
    
    /// Checks whether the store contains an entry for the specified key.
    @inlinable
    public func hasEntry(for key: LocalPreferenceKey<some Any>.Key) -> Bool {
        defaults.hasEntry(for: key.value)
    }
    
    /// Removes the entry for the specified key from the store.
    @inlinable
    public func removeEntry(for key: LocalPreferenceKey<some Any>) {
        removeEntry(for: key.key)
    }
    
    /// Removes the entry for the specified key from the store.
    @inlinable
    public func removeEntry(for key: LocalPreferenceKey<some Any>.Key) {
        defaults.removeObject(forKey: key.value)
    }
    
    /// Accesses a ``LocalPreferenceKey``'s persisted value.
    @inlinable
    public subscript<T>(key: LocalPreferenceKey<T>) -> T {
        get {
            key.readOrDefault(in: defaults)
        }
        nonmutating set {
            try? key.write(newValue, in: defaults)
        }
    }
    
    /// Accesses a ``LocalPreferenceKey``'s persisted value.
    @_disfavoredOverload
    @inlinable
    public subscript<T>(key: LocalPreferenceKey<T>) -> T? { // we always return nonnil values, but allow nil-resetting
        get {
            key.readOrDefault(in: defaults)
        }
        nonmutating set {
            try? key.write(newValue, in: defaults)
        }
    }
}


extension UserDefaults {
    @inlinable
    func hasEntry(for key: String) -> Bool {
        object(forKey: key) != nil
    }
}
