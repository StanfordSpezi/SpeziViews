//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable syntactic_sugar

import Foundation
import SpeziFoundation


/// Container type for ``LocalPreferenceKey`` definitions.
///
/// Define a ``LocalPreferenceKey`` by placing it in an extension on this type:
/// ```swift
/// extension LocalPreferenceKeys {
///     static let didReview = LocalPreferenceKey<Bool>("didReview", default: false)
/// }
/// ```
public class LocalPreferenceKeys: @unchecked Sendable {}


/// Used to identify data persisted to the `UserDefaults`.
///
/// You can either use the ``LocalPreferencesStore`` directly to access the key's data, or you can use the ``LocalPreference`` property wrapper within a SwiftUI view.
///
/// You define a key by placing it in an extension on the `LocalPreferenceKey` type:
/// ```swift
/// extension LocalPreferenceKeys {
///     static let prefersMetricUnits = LocalPreferenceKey<Bool>("prefersMetricUnits", default: true)
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
/// - ``init(_:default:)-1uj4h``
/// - ``init(_:default:)-90if0``
/// - ``init(_:encoder:decoder:default:)``
///
/// ### Supporting Types
/// - ``LocalPreferencesStore``
/// - ``LocalPreferenceKeys/Namespace``
/// - ``LocalPreferenceKeys``
public final class LocalPreferenceKey<Value: SendableMetatype>: LocalPreferenceKeys, Hashable, @unchecked Sendable {
    @usableFromInline
    enum ReadResult {
        case empty
        case value(Value)
        case failure(any Error)
    }
    
    /// The actual key that is used when reading or writing a value to the `UserDefaults` using this key.
    public let key: Key
    @usableFromInline let `default`: @Sendable () -> Value
    /// Reads the key's value from the `UserDefaults`. Returns `nil` if no value existed, or the decoding failed.
    @usableFromInline let _read: @Sendable (UserDefaults) -> ReadResult // swiftlint:disable:this identifier_name
    @usableFromInline let _write: @Sendable (Value?, UserDefaults) throws -> Void // swiftlint:disable:this identifier_name
    
    private init(
        key: Key,
        default: @escaping @Sendable () -> Value,
        read: @escaping @Sendable (Key, UserDefaults) -> ReadResult,
        write: @escaping @Sendable (Key, Value?, UserDefaults) throws -> Void
    ) {
        self.key = key
        self.default = `default`
        self._read = { read(key, $0) }
        self._write = { try write(key, $0, $1) }
    }
    
    @inlinable
    public static func == (lhs: LocalPreferenceKey, rhs: LocalPreferenceKey) -> Bool {
        ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
    
    // MARK: Operations
    
    @inlinable
    func read(in defaults: UserDefaults) -> ReadResult {
        _read(defaults)
    }
    
    @inlinable
    func readOrDefault(in defaults: UserDefaults) -> Value {
        switch read(in: defaults) {
        case .value(let value):
            value
        case .empty, .failure:
            `default`()
        }
    }
    
    @inlinable
    func write(_ newValue: Value?, in defaults: UserDefaults) throws {
        try _write(newValue, defaults)
    }
}


extension LocalPreferenceKey {
    // MARK: Initializers
    
    /// Creates a `LocalPreferenceKey`.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter default: The default value, which will be used if no entry exists for the key, or the preferences store failed to decode the value.
    ///
    /// - Note: If `Value` is an `Optional` type, the default value will be ignored, and reading a key for which no value exists in the `UserDefaults` store will always return `nil`.
    public convenience init(
        _ key: Key,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: _HasDirectUserDefaultsSupport {
        self.init(key: key, default: `default`) { key, defaults in
            switch Value._load(from: defaults, forKey: key.value) {
            case .none: .empty
            case .some(let value): .value(value)
            }
        } write: { key, newValue, defaults in
            try newValue._store(to: defaults, forKey: key.value)
        }
    }
    
    /// Creates a `LocalPreferenceKey` for a `RawRepresentable` value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter default: The default value, which will be used if no entry exists for the key, or the preferences store failed to decode the value.
    ///
    /// - Note: If `Value` is an `Optional` type, the default value will be ignored, and reading a key for which no value exists in the `UserDefaults` store will always return `nil`.
    public convenience init(
        _ key: Key,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: RawRepresentable, Value.RawValue: _HasDirectUserDefaultsSupport, Value.RawValue: SendableMetatype {
        self.init(rawRepresentable: Value.self, key: key, mapFrom: { $0 }, mapTo: { $0 }, default: `default`())
    }
    
    
    /// Creates a `LocalPreferenceKey` for a `Codable` value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter encoder: The encoder to use when writing values for this key to the ``LocalPreferencesStore``
    /// - parameter decoder: The decoder to use when reading values for this key from the ``LocalPreferencesStore``
    /// - parameter default: The default value, which will be used if no entry exists for the key, or the preferences store failed to decode the value.
    ///
    /// - Note: If `Value` is an `Optional` type, the default value will be ignored, and reading a key for which no value exists in the `UserDefaults` store will always return `nil`.
    @_disfavoredOverload
    public convenience init(
        _ key: Key,
        encoder: some TopLevelEncoder<Data> & Sendable = JSONEncoder(),
        decoder: some TopLevelDecoder<Data> & Sendable = JSONDecoder(),
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: Codable {
        self.init(codable: Value.self, key: key, encoder: encoder, decoder: decoder, mapFrom: { $0 }, mapTo: { $0 }, default: `default`())
    }
    
    
    // MARK: Initializers for Optional Values
    
    /// Creates a `LocalPreferenceKey` for an optional value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    public convenience init<V: SendableMetatype>(
        _ key: Key
    ) where Value == Optional<V>, Value: _HasDirectUserDefaultsSupport {
        self.init(key, default: nil)
    }
    
    /// Creates a `LocalPreferenceKey` for an optional `RawRepresentable` value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    public convenience init<V: RawRepresentable & SendableMetatype>(
        _ key: Key
    ) where Value == Optional<V>, V.RawValue: _HasDirectUserDefaultsSupport, V.RawValue: SendableMetatype {
        self.init(rawRepresentable: V.self, key: key, mapFrom: { $0 }, mapTo: { $0 }, default: nil)
    }
    
    /// Creates a `LocalPreferenceKey` for an optional `Codable` value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter encoder: The encoder to use when writing values for this key to the ``LocalPreferencesStore``
    /// - parameter decoder: The decoder to use when reading values for this key from the ``LocalPreferencesStore``
    @_disfavoredOverload
    public convenience init<V: Codable & SendableMetatype>(
        _ key: Key,
        encoder: some TopLevelEncoder<Data> & Sendable = JSONEncoder(),
        decoder: some TopLevelDecoder<Data> & Sendable = JSONDecoder()
    ) where Value == Optional<V> {
        self.init(codable: V.self, key: key, encoder: encoder, decoder: decoder, mapFrom: { $0 }, mapTo: { $0 }, default: nil)
    }
    
    
    // MARK: Initializer Utils
    
    // utility initializer for unifying the handling of non-optional and optional RawRepresentable `Value` keys.
    private convenience init<R: RawRepresentable>(
        rawRepresentable _: R.Type,
        key: Key,
        mapFrom: @escaping @Sendable (R) -> Value,
        mapTo: @escaping @Sendable (Value) -> R?,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where R.RawValue: _HasDirectUserDefaultsSupport, R: SendableMetatype {
        self.init(key: key, default: `default`) { key, defaults in
            switch R.RawValue._load(from: defaults, forKey: key.value).flatMap(R.init(rawValue:)) {
            case .none: .empty
            case .some(let value): .value(mapFrom(value))
            }
        } write: { key, newValue, defaults in
            switch newValue {
            case .none:
                defaults.removeObject(forKey: key.value)
            case .some(let newValue):
                try mapTo(newValue)?.rawValue._store(to: defaults, forKey: key.value)
            }
        }
    }
    
    private convenience init<C: Codable & SendableMetatype>(
        codable _: C.Type,
        key: Key,
        encoder: some TopLevelEncoder<Data> & Sendable,
        decoder: some TopLevelDecoder<Data> & Sendable,
        mapFrom: @escaping @Sendable (C) -> Value,
        mapTo: @escaping @Sendable (Value) -> C?,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: Codable {
        self.init(key: key, default: `default`) { key, defaults in
            switch defaults.data(forKey: key.value) {
            case .none:
                return .empty
            case .some(let data):
                do {
                    return .value(mapFrom(try decoder.decode(C.self, from: data)))
                } catch {
                    return .failure(error)
                }
            }
        } write: { key, newValue, defaults in
            if let newValue = newValue.flatMap(mapTo) {
                let data = try encoder.encode(newValue)
                defaults.set(data, forKey: key.value)
            } else {
                defaults.removeObject(forKey: key.value)
            }
        }
    }
}


extension LocalPreferenceKey {
    /// Specifies how the preference is identified within the `UserDefaults`.
    ///
    /// ## Topics
    /// ### Initializers
    /// - ``init(_:in:)``
    /// - ``init(verbatim:in:)``
    /// - ``init(stringLiteral:)``
    public struct Key: Hashable, ExpressibleByStringLiteral, Sendable {
        public let value: String
        @usableFromInline let isKVOCompatible: Bool
        
        /// Creates a key.
        ///
        /// The actual key value used when persisting data associated with this key in the `UserDefaults` is derived from `key` and `namespace`.
        /// Additionally, this function normalizes the key (by replacing all `.`s with `_`s), in order to achieve improved performance when observing the `UserDefaults` for changes.
        /// You can obtain the actual key via the ``value`` property.
        ///
        /// - Note: Use the ``init(verbatim:in:)`` initializer to disable the normalization.
        ///     The resulting key can be used the same way, and will behave the same as keys created via ``init(_:in:)``, but using it with ``LocalPreference`` will result in slower code.
        @inlinable
        public init(_ key: String, in namespace: LocalPreferenceKeys.Namespace = .app) {
            // We want to be able to observe these entries via KVO, which doesn't work if they appear to be keyPaths,
            // therefore we replace all '.' with '_'.
            value = namespace.format(keyName: key).replacingOccurrences(of: ".", with: "_")
            isKVOCompatible = true
        }
        
        /// Creates a key.
        ///
        /// The actual key value used when persisting data associated with this key in the `UserDefaults` is derived from `key` and `namespace`.
        /// You can obtain the actual key via the ``value`` property.
        ///
        /// - Note: This initializer does not normalize the key, which will result in slower code if the key contains any period characters (`.`).
        ///     Use ``init(_:in:)`` instead if possible.
        @inlinable
        public init(verbatim key: String, in namespace: LocalPreferenceKeys.Namespace = .app) {
            value = namespace.format(keyName: key)
            isKVOCompatible = !value.contains(".")
        }
        
        /// Creates a key from a `String` literal.
        ///
        /// Creating a key via a `String` literal is equivalent to `Key(value, in: .app)`.
        /// (I.e., creating a key via ``init(_:in:)`` in the ``LocalPreferenceKeys/Namespace/app`` namespace.)
        @inlinable
        public init(stringLiteral value: String) {
            self.init(value, in: .app)
        }
    }
}


extension LocalPreferenceKeys {
    /// A namespace used to avoid conflicts between keys within a single `UserDefaults` store.
    ///
    /// ## Topics
    ///
    /// ### Creating Namespaces
    /// - ``app``
    /// - ``bundle(_:)``
    /// - ``custom(_:)``
    public struct Namespace: Sendable {
        @usableFromInline let value: String
        
        @inlinable
        init(value: String) {
            self.value = value
        }
        
        @inlinable
        func format(keyName: String) -> String {
            if value.isEmpty {
                keyName
            } else {
                "\(value):\(keyName)"
            }
        }
    }
}


extension LocalPreferenceKeys.Namespace {
    /// The default namespace, based on the current app's bundle id.
    @inlinable public static var app: Self {
        .bundle(.main)
    }
    
    /// A special namespace that causes local preference values be written at the global scope.
    @inlinable public static var none: Self {
        .custom("")
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
