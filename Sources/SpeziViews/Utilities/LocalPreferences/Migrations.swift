//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import SpeziFoundation


extension LocalPreferencesStore {
    /// A migration of a local preference.
    ///
    /// Migrations should be idempotent, i.e. once a migration has been run, any subsequent runs should simply have no effect.
    public protocol Migration {
        /// Runs the migration in the specified preferences store.
        @_spi(Internal)
        func run(in store: LocalPreferencesStore) throws
    }
    
    
    /// A migration that migrates from an old key to a new key, keeping the value.
    ///
    /// Use this migration if you want to rename a key, but the value (and its type) remain unchanged.
    public struct MigrateName<T>: Migration where T: SendableMetatype {
        private let oldKey: LocalPreferenceKey<T>.Key
        private let newKey: LocalPreferenceKey<T>.Key
        
        /// Creates a name migration.
        public init(
            from oldKey: LocalPreferenceKey<T>.Key,
            to newKey: LocalPreferenceKey<T>.Key
        ) {
            self.oldKey = oldKey
            self.newKey = newKey
        }
        
        @_documentation(visibility: internal)
        public func run(in store: LocalPreferencesStore) throws {
            guard let value = store.defaults.object(forKey: oldKey.value) else {
                return
            }
            store.defaults.removeObject(forKey: oldKey.value)
            store.defaults.set(value, forKey: newKey.value)
        }
    }
    
    
    /// A migration that migrates a value to a different type.
    ///
    /// Use this migration if you want to change the persisted type of a preference, in a way that migrates over the persisted value.
    ///
    /// The old and new ``LocalPreferenceKey`` (i.e., the key being migrated from and the key being migrated to)
    /// are allowed to point to the same actual entry in the `UserDefaults`, i.e. have the same underlying ``LocalPreferenceKey/Key``.
    /// In this case the migration will simply read the old value, transform it into a new value of the new type, and write that into the `UserDefaults`, overriding the old value.
    /// If the underlying ``LocalPreferenceKey/Key``s are different, the old key's entry is removed from the store.
    ///
    /// Using ``MigrateValue`` with two keys with equal types but different underlying keys and an identity closure is identical to a ``MigrateName`` between the two keys.
    public struct MigrateValue<Old, New>: Migration where Old: SendableMetatype, New: SendableMetatype {
        private let oldKey: LocalPreferenceKey<Old>
        private let newKey: LocalPreferenceKey<New>
        private let transform: (Old) throws -> New
        
        /// Creates a value migration.
        public init(
            from oldKey: LocalPreferenceKey<Old>,
            to newKey: LocalPreferenceKey<New>,
            transform: @escaping (Old) throws -> New
        ) {
            self.oldKey = oldKey
            self.newKey = newKey
            self.transform = transform
        }
        
        @_documentation(visibility: internal)
        public func run(in store: LocalPreferencesStore) throws {
            switch oldKey.read(in: store.defaults) {
            case .empty:
                return
            case .value(let oldValue):
                store.removeEntry(for: oldKey)
                let newValue = try transform(oldValue)
                store[newKey] = newValue
            case .failure:
                // the store does contains a value for the old key, but we can't decode it.
                switch newKey.read(in: store.defaults) {
                case .empty:
                    // ... and it contains no value for the new key.
                    // in this case we remove the old entry,
                    // causing the next access using the new key to simply fall back to that key's default value
                    store.removeEntry(for: oldKey)
                case .value:
                    // ... and it contains a (valid & decodable) value for the new key.
                    // we interpret this as the migration already having run and having been successful,
                    // and there not being anything for us to do.
                    return
                case .failure:
                    // ... and we also can't decode the value using the new key.
                    // in this case we simply do nothing, and assume that the value is already stored using the new key,
                    // and allow the next regular read to fall back to the key's default value
                    return
                }
            }
        }
    }
}


extension LocalPreferencesStore {
    /// Performs one or multiple migrations.
    ///
    /// - throws: If any of the migrations throws an error. In this case none of the migrations that have already run and were successful will be rolled back,
    ///     and none of the remaining migrations that haven't yet been run will be performed.
    public func runMigrations<each M: Migration>(_ migration: repeat each M) throws {
        for migration in repeat each migration {
            try migration.run(in: self)
        }
    }
}
