//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import SpeziFoundation
import SwiftUI


/// Types which can be directly put into a UserDefaults store (bc there is an official overload of the `set(_:forKey:)` function).
public protocol _HasDirectUserDefaultsSupport {
    static func _load(from defaults: UserDefaults, forKey key: String) -> Self?
    func _store(to defaults: UserDefaults, forKey key: String) throws
}


extension Bool: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Bool? { // swiftlint:disable:this discouraged_optional_boolean
        defaults.hasEntry(for: key) ? defaults.bool(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Int: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Int? {
        defaults.hasEntry(for: key) ? defaults.integer(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension String: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> String? {
        defaults.string(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Double: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Double? {
        defaults.hasEntry(for: key) ? defaults.double(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Float: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Float? {
        defaults.hasEntry(for: key) ? defaults.float(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Data: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension URL: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> URL? {
        defaults.url(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Optional: _HasDirectUserDefaultsSupport where Wrapped: _HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Self? {
        if let value = Wrapped._load(from: defaults, forKey: key) {
            Self?.some(value)
        } else {
            Self?.none
        }
    }
    
    public func _store(to defaults: UserDefaults, forKey key: String) throws {
        if let self = self {
            try self._store(to: defaults, forKey: key)
        } else {
            defaults.removeObject(forKey: key)
        }
    }
}


/// A type-safe wrapper around `UserDefaults`.
///
/// ## Topics
///
/// ### Static Properties
/// - ``standard``
///
/// ### Subscripts
/// - ``subscript(_:)->T``
/// - ``subscript(_:)->T?``
///
/// ### Initializers
/// - ``init(defaults:)``
public struct LocalPreferencesStore: @unchecked Sendable {
    public static let standard = LocalPreferencesStore(defaults: .standard)
    
    @usableFromInline let defaults: UserDefaults
    
    @inlinable
    public init(defaults: UserDefaults) {
        self.defaults = defaults
    }
    
    /// Accesses a ``LocalPreferenceKey``'s persisted value.
    @inlinable
    public subscript<T>(key: LocalPreferenceKey<T>) -> T {
        get { key.read(defaults) }
        nonmutating set {
            try? key.write(newValue, defaults)
        }
    }
    
    /// Accesses a ``LocalPreferenceKey``'s persisted value.
    @_disfavoredOverload
    @inlinable
    public subscript<T>(key: LocalPreferenceKey<T>) -> T? { // we always return nonnil values, but allow nil-resetting
        get { key.read(defaults) }
        nonmutating set {
            try? key.write(newValue, defaults)
        }
    }
}


extension UserDefaults {
    fileprivate func hasEntry(for key: String) -> Bool {
        object(forKey: key) != nil
    }
}
