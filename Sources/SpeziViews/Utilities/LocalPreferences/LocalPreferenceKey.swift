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
/// - ``LocalPreferenceNamespace``
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
    
    /// Creates a `LocalPreferenceKey`.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter default: The default value, which will be used if no entry exists for the key, or the preferences store failed to decode the value.
    public convenience init(
        _ key: Key,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: _HasDirectUserDefaultsSupport {
        self.init(key: key, default: `default`) { key, defaults in
            switch Value._load(from: defaults, forKey: key.value) {
            case nil: .empty
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
    public convenience init(
        _ key: Key,
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: RawRepresentable, Value.RawValue: _HasDirectUserDefaultsSupport, Value.RawValue: SendableMetatype {
        self.init(key: key, default: `default`) { key, defaults in
            switch Value.RawValue._load(from: defaults, forKey: key.value).flatMap(Value.init(rawValue:)) {
            case nil: .empty
            case .some(let value): .value(value)
            }
        } write: { key, newValue, defaults in
            if let rawValue = newValue?.rawValue {
                try rawValue._store(to: defaults, forKey: key.value)
            } else {
                try Optional<Value.RawValue>.none._store(to: defaults, forKey: key.value)
            }
        }
    }
    
    /// Creates a `LocalPreferenceKey` for a `Codable` value.
    ///
    /// - parameter key: The key definition that will be used when reading or writing data to the `UserDefaults`
    /// - parameter encoder: The encoder to use when writing values for this key to the ``LocalPreferencesStore``
    /// - parameter decoder: The decoder to use when reading values for this key from the ``LocalPreferencesStore``
    /// - parameter default: The default value, which will be used if no entry exists for the key, or the preferences store failed to decode the value.
    @_disfavoredOverload
    public convenience init(
        _ key: Key,
        encoder: some TopLevelEncoder<Data> & Sendable = JSONEncoder(),
        decoder: some TopLevelDecoder<Data> & Sendable = JSONDecoder(),
        default: @autoclosure @escaping @Sendable () -> Value
    ) where Value: Codable {
        self.init(key: key, default: `default`) { key, defaults in
            switch defaults.data(forKey: key.value) {
            case .none:
                return .empty
            case .some(let data):
                do {
                    return .value(try decoder.decode(Value.self, from: data))
                } catch {
                    return .failure(error)
                }
            }
        } write: { key, newValue, defaults in
            let data = try encoder.encode(newValue)
            defaults.set(data, forKey: key.value)
        }
    }
    
    @inlinable
    public static func == (lhs: LocalPreferenceKey, rhs: LocalPreferenceKey) -> Bool {
        lhs.key == rhs.key
    }
    
    @inlinable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(key)
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
        public init(_ key: String, in namespace: LocalPreferenceNamespace = .app) {
            // We want to be able to observe these entries via KVO, which doesn't work if they appear to be keyPaths,
            // therefore we replace all '.' with '_'.
            value = "\(namespace.value):\(key)".replacingOccurrences(of: ".", with: "_")
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
        public init(verbatim key: String, in namespace: LocalPreferenceNamespace = .app) {
            value = "\(namespace.value):\(key)"
            isKVOCompatible = !value.contains(".")
        }
        
        /// Creates a key from a `String` literal.
        ///
        /// Creating a key via a `String` literal is equivalent to `Key(value, in: .app)`.
        /// (I.e., creating a key via ``init(_:in:)`` in the ``LocalPreferenceNamespace/app`` namespace.)
        @inlinable
        public init(stringLiteral value: String) {
            self.init(value, in: .app)
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


// MARK: Internal Stuff

extension LocalPreferenceKey.ReadResult {
    var value: Value? {
        switch self {
        case .value(let value):
            value
        case .empty, .failure:
            nil
        }
    }
    
    var error: (any Error)? {
        switch self {
        case .failure(let error):
            error
        case .empty, .value:
            nil
        }
    }
}


extension LocalPreferenceKey.ReadResult: Equatable where Value: Equatable {
    @usableFromInline
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            true
        case let (.value(lhs), .value(rhs)):
            lhs == rhs
        case let (.failure(lhs), .failure(rhs)):
            // https://github.com/swiftlang/swift/issues/85111
            (lhs as any Equatable).isEqual(to: rhs)
        default:
            false
        }
    }
}
