//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable identifier_name syntactic_sugar

public import Foundation


/// Types which can be directly placed into a `UserDefaults` store.
///
/// - Note: This type is public, but no additional conformances should be added to it (beyond what is defined by SpeziViews)
public protocol HasDirectUserDefaultsSupport: Sendable, SendableMetatype {
    /// Constructs an instance of the type by loading it from a `UserDefaults` store.
    @inlinable
    static func _load(from defaults: UserDefaults, forKey key: String) -> Self?
    
    /// Persists an instance of the type to a `UserDefaults` store.
    @inlinable
    func _store(to defaults: UserDefaults, forKey key: String) throws
}


extension Bool: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Bool? { // swiftlint:disable:this discouraged_optional_boolean
        defaults.hasEntry(for: key) ? defaults.bool(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Int: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Int? {
        defaults.hasEntry(for: key) ? defaults.integer(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension String: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> String? {
        defaults.string(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Double: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Double? {
        defaults.hasEntry(for: key) ? defaults.double(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Float: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Float? {
        defaults.hasEntry(for: key) ? defaults.float(forKey: key) : nil
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Date: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Date? {
        defaults.object(forKey: key) as? Date
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Data: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Data? {
        defaults.data(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension URL: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> URL? {
        defaults.url(forKey: key)
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Optional: HasDirectUserDefaultsSupport where Wrapped: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Optional<Optional<Wrapped>> {
        if let value = Wrapped._load(from: defaults, forKey: key) {
            Optional<Optional<Wrapped>>.some(.some(value))
        } else {
            Optional<Optional<Wrapped>>.some(.none)
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

extension Array: HasDirectUserDefaultsSupport where Element: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Self? {
        defaults.array(forKey: key) as? Self
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}

extension Dictionary: HasDirectUserDefaultsSupport where Key == String, Value: HasDirectUserDefaultsSupport {
    public static func _load(from defaults: UserDefaults, forKey key: String) -> Self? {
        defaults.dictionary(forKey: key) as? Self
    }
    public func _store(to defaults: UserDefaults, forKey key: String) {
        defaults.set(self, forKey: key)
    }
}
