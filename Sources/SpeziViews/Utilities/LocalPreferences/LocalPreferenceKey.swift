//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order function_default_parameter_at_end

import Foundation


/// Used to identify data persisted to the `UserDefaults`.
///
/// You can either use the ``LocalPreferencesStore`` directly to access the key's data, or you can use the ``LocalPreference`` property wrapper within a SwiftUI view.
///
/// You define a key by placing it in an extension on the `LocalPreferenceKey` type:
/// ```swift
/// extension LocalPreferenceKey {
///     static var prefersMetricUnits: LocalPreferenceKey<Bool> {
///         .make("prefersMetricUnits", default: true)
///     }
/// }
/// ```
///
/// You can then access the value stored for the key:
/// ```swift
/// // in regular Swift code:
/// LocalPreferencesStore.standard[.prefersMetricUnits] = false
///
/// // in a View:
/// @LocalPreference(.prefersMetricUnits) var prefersMetricUnits
/// ```
///
/// ## Topics
///
/// ### Creating Keys
/// - ``make(namespace:_:default:)-9b4an``
/// - ``make(namespace:_:default:)-7elwj``
/// - ``make(namespace:_:default:)-7hzi7``
///
/// ### Supporting Types
/// - ``LocalPreferencesStore``
/// - ``LocalPreferenceNamespace``
public struct LocalPreferenceKey<Value: SendableMetatype>: Sendable {
    /// The actual key that is used when reading or writing a value to the `UserDefaults` using this key.
    ///
    /// - Note: This value is not identical to the key passed to e.g. ``make(namespace:_:default:)-9b4an``;
    ///     instead, it is derived from the namespace and key, in a way that ensures compatibilty with the `UserDefaults` API.
    public let rawValue: String
    @usableFromInline let read: @Sendable (UserDefaults) -> Value
    @usableFromInline let write: @Sendable (Value?, UserDefaults) throws -> Void
    
    private init(
        namespace: LocalPreferenceNamespace,
        key: String,
        read: @escaping @Sendable (String, UserDefaults) -> Value,
        write: @escaping @Sendable (String, Value?, UserDefaults) throws -> Void
    ) {
        // We want to be able to observe these entries via KVO, which doesn't work if they appear to be keyPaths,
        // therefore we replace all '.' with '_'.
        let key = "\(namespace.value).\(key)".replacingOccurrences(of: ".", with: "_")
        self.rawValue = key
        self.read = { read(key, $0) }
        self.write = { try write(key, $0, $1) }
    }
    
    /// Creates a `LocalPreferenceKey`.
    public static func make(
        namespace: LocalPreferenceNamespace = .app,
        _ key: String,
        default makeDefault: @autoclosure @escaping @Sendable () -> Value
    ) -> Self where Value: _HasDirectUserDefaultsSupport {
        Self(namespace: namespace, key: key) { key, defaults in
            Value._load(from: defaults, forKey: key) ?? makeDefault()
        } write: { key, newValue, defaults in
            try newValue._store(to: defaults, forKey: key)
        }
    }
    
    /// Creates a `LocalPreferenceKey` for a `RawRepresentable` value.
    public static func make(
        namespace: LocalPreferenceNamespace = .app,
        _ key: String,
        default makeDefault: @autoclosure @escaping @Sendable () -> Value
    ) -> Self where Value: RawRepresentable, Value.RawValue: _HasDirectUserDefaultsSupport, Value.RawValue: SendableMetatype {
        Self(namespace: namespace, key: key) { key, defaults in
            Value.RawValue._load(from: defaults, forKey: key).flatMap(Value.init(rawValue:)) ?? makeDefault()
        } write: { key, newValue, defaults in
            if let rawValue = newValue?.rawValue {
                try rawValue._store(to: defaults, forKey: key)
            } else {
                try Optional<Value.RawValue>.none._store(to: defaults, forKey: key)
            }
        }
    }
    
    /// Creates a `LocalPreferenceKey` for a `Codable` value.
    @_disfavoredOverload
    public static func make(
        namespace: LocalPreferenceNamespace = .app,
        _ key: String,
        default makeDefault: @autoclosure @escaping @Sendable () -> Value
    ) -> Self where Value: Codable {
        Self(namespace: namespace, key: key) { key, defaults in
            let decoder = JSONDecoder()
            if let data = defaults.data(forKey: key) {
                return (try? decoder.decode(Value.self, from: data)) ?? makeDefault()
            } else {
                return makeDefault()
            }
        } write: { key, newValue, defaults in
            let encoder = JSONEncoder()
            let data = try encoder.encode(newValue)
            defaults.set(data, forKey: key)
        }
    }
}


/// A namespace used to avoid conflicts between keys within a single `UserDefaults` store.
///
/// ## Topics
///
/// ### Creating Namespaces
/// - ``app``
/// - ``bundle(_:)``
/// - ``custom(_:)``
public struct LocalPreferenceNamespace: Sendable {
    @usableFromInline let value: String
    
    @inlinable
    init(value: String) {
        self.value = value
    }
}


extension LocalPreferenceNamespace {
    /// The default namespace, based on the current app's bundle id.
    @inlinable public static var app: Self {
        .bundle(.main)
    }
    
    /// Creates a namespace that scopes keys based on a bundle id.
    @inlinable
    public static func bundle(_ bundle: Bundle) -> Self {
        guard let bundleId = bundle.bundleIdentifier else {
            preconditionFailure("Unable to construct '\(Self.self)': missing bundle id")
        }
        return Self(value: bundleId)
    }
    
    /// Creates a namespace that scopes keys based on a custom string.
    @inlinable
    public static func custom(_ value: String) -> Self {
        Self(value: value)
    }
}
