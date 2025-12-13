//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable empty_string discouraged_optional_boolean type_body_length

import Foundation
import SpeziFoundation
@testable import SpeziViews
import Testing


@Suite(.serialized)
final class LocalPreferenceTests {
    let suiteName = "edu.stanford.SpeziViews.unitTests"
    let suite: UserDefaults
    let store: LocalPreferencesStore
    
    init() throws {
        suite = try #require(UserDefaults(suiteName: suiteName))
        store = LocalPreferencesStore(defaults: suite)
    }
    
    deinit { // swiftlint:disable:this type_contents_order
        UserDefaults.standard.removePersistentDomain(forName: suiteName)
    }
    
    
    @Test
    func simpleTypes() throws {
        #expect(LocalPreferenceKeys.string.key.value == "edu_stanford_SpeziViews_unitTests:string")
        #expect(LocalPreferenceKeys.stringOpt.key.value == "edu_stanford_SpeziViews_unitTests:stringOpt")
        #expect(store[.string] == "")
        #expect(store[.stringOpt] == nil)
        #expect(suite.string(forKey: "edu_stanford_SpeziViews_unitTests:string") == nil)
        store[.string] = "abc"
        #expect(store[.string] == "abc")
        #expect(try #require(suite.string(forKey: "edu_stanford_SpeziViews_unitTests:string")) == "abc")
    }
    
    
    @Test
    func userDefaultsBehaviours() throws {
        let rawKey = "_bool1"
        let key = LocalPreferenceKey<Bool>(.init(verbatim: rawKey, in: .none), default: false)
        #expect(!suite.bool(forKey: rawKey))
        suite.set(true, forKey: rawKey)
        #expect(suite.bool(forKey: rawKey))
        #expect(store[key])
        
        suite.set("true", forKey: rawKey)
        #expect(suite.bool(forKey: rawKey))
        #expect(store[key])
        
        suite.set("false", forKey: rawKey)
        #expect(!suite.bool(forKey: rawKey))
        #expect(!store[key])
        
        suite.set("abc", forKey: rawKey)
        #expect(!suite.bool(forKey: rawKey))
        #expect(!store[key])
        
        suite.set("123", forKey: rawKey)
        #expect(!suite.bool(forKey: rawKey))
        #expect(!store[key])
        
        store[key] = true
        #expect(suite.bool(forKey: rawKey))
        #expect(store[key])
        
        suite.removeObject(forKey: rawKey)
        #expect(!suite.bool(forKey: rawKey))
        #expect(!store[key])
        
        let suite1 = UserDefaults.standard
        let suite2 = try #require(UserDefaults(suiteName: "test"))
        suite1.set("world", forKey: "hello")
        #expect(suite1.string(forKey: "hello") == "world")
        #expect(suite2.string(forKey: "hello") == nil)
        
        suite2.set("hello", forKey: "world")
        #expect(suite1.string(forKey: "world") == nil)
        #expect(suite2.string(forKey: "world") == "hello")
        suite1.addSuite(named: "test")
        #expect(suite1.string(forKey: "world") == "hello")
    }
    
    
    @Test
    func directlySupportedTypes() throws {
        func imp<T: _HasDirectUserDefaultsSupport & Equatable & Sendable>(_: T.Type, defaultValue: T, testValue: T) throws {
            let key = LocalPreferenceKey<T>(.init(verbatim: "testKey", in: .none), default: defaultValue)
            store.removeEntry(for: key)
            #expect(store[key] == defaultValue)
            #expect(suite.object(forKey: key.key.value) == nil)
            store[key] = testValue
            if let testValue = testValue as? any AnyOptional, testValue.isNone {
                #expect(suite.object(forKey: key.key.value) == nil)
            } else {
                #expect(suite.object(forKey: key.key.value) != nil)
            }
            #expect(store[key] == testValue)
            store[key] = nil
            #expect(suite.object(forKey: key.key.value) == nil)
            #expect(store[key] == defaultValue)
        }
        
        try imp(Bool.self, defaultValue: false, testValue: true)
        try imp(Int.self, defaultValue: 0, testValue: 12)
        try imp(String.self, defaultValue: "", testValue: "heyyy")
        try imp(Double.self, defaultValue: 2, testValue: 4.7)
        try imp(Float.self, defaultValue: 5, testValue: 3.1)
        try imp(Data.self, defaultValue: Data([1, 2, 3]), testValue: Data([4, 5, 6]))
        try imp(URL.self, defaultValue: URL(filePath: "/Users/Spezi/"), testValue: URL(filePath: "/Users/Spezi/Desktop"))
        
        try imp(Bool?.self, defaultValue: nil, testValue: false)
        try imp(Bool?.self, defaultValue: nil, testValue: nil)
        try imp(Bool?.self, defaultValue: nil, testValue: true)
        try imp(Int?.self, defaultValue: nil, testValue: 12)
        try imp(String?.self, defaultValue: nil, testValue: "hello")
        try imp(Double?.self, defaultValue: nil, testValue: 1.1)
        try imp(Float?.self, defaultValue: nil, testValue: 2.2)
        try imp(Data?.self, defaultValue: nil, testValue: Data([0, 9, 8]))
        try imp(URL?.self, defaultValue: nil, testValue: URL(filePath: "/Users/Spezi/Desktop/file.txt"))
    }
    
    
    @Test
    func optionalDirectlySupportedTypes() throws {
        func imp(testValue: Bool?) {
            let key = LocalPreferenceKey<Bool?>(.init(verbatim: "optBoolTestKey", in: .none))
            store.removeEntry(for: key)
            #expect(store[key] == nil)
            #expect(suite.object(forKey: key.key.value) == nil)
            store[key] = testValue
            if testValue == nil {
                #expect(suite.object(forKey: key.key.value) == nil)
            } else {
                #expect(suite.object(forKey: key.key.value) != nil)
            }
            #expect(store[key] == testValue)
            store[key] = nil
            #expect(suite.object(forKey: key.key.value) == nil)
            #expect(store[key] == nil)
        }
        imp(testValue: nil)
        imp(testValue: false)
        imp(testValue: true)
    }
    
    
    @Test
    func rawRepresentableTypes() throws {
        func imp<R: RawRepresentable & Equatable & Sendable & SendableMetatype>(
            _: R.Type,
            defaultValue: R,
            testValues: [R]
        ) throws where R.RawValue: _HasDirectUserDefaultsSupport {
            let key = LocalPreferenceKey<R>("rrKey", default: defaultValue)
            store.removeEntry(for: key)
            #expect(!store.hasEntry(for: key))
            #expect(store[key] == defaultValue)
            for testValue in testValues {
                store[key] = testValue
                #expect(store.hasEntry(for: key))
                #expect(store[key] == testValue)
                store.removeEntry(for: key)
                #expect(!store.hasEntry(for: key))
                #expect(store[key] == defaultValue)
            }
            store[key] = nil
            #expect(!store.hasEntry(for: key))
            #expect(store[key] == defaultValue)
            store[key] = defaultValue
            #expect(store.hasEntry(for: key))
            #expect(store[key] == defaultValue)
        }
        
        struct IntID: RawRepresentable, Equatable {
            let rawValue: Int
        }
        struct StringID: RawRepresentable, Equatable {
            let rawValue: String
        }
        
        try imp(
            IntID.self,
            defaultValue: IntID(rawValue: 0),
            testValues: [IntID(rawValue: 1), IntID(rawValue: 2), IntID(rawValue: 3)]
        )
        try imp(
            StringID.self,
            defaultValue: StringID(rawValue: ""),
            testValues: [StringID(rawValue: "a"), StringID(rawValue: "b"), StringID(rawValue: "c")]
        )
    }
    
    
    @Test
    func optionalRawRepresentableTypes() throws {
        func imp<R: RawRepresentable & Equatable & Sendable & SendableMetatype>(
            _: R.Type,
            testValues: [Optional<R>]
        ) throws where R.RawValue: _HasDirectUserDefaultsSupport {
            let key1 = LocalPreferenceKey<R?>("rrKey")
            let key2 = LocalPreferenceKey<R?>("rrKey")
            
            store.removeEntry(for: key1)
            #expect(!store.hasEntry(for: key1))
            #expect(!store.hasEntry(for: key2))
            #expect(store[key1] == nil)
            #expect(store[key1] == store[key2])
            
            for testValue in testValues {
                store[key1] = testValue
                #expect(store.hasEntry(for: key1) == (testValue != nil))
                #expect(store.hasEntry(for: key2) == (testValue != nil))
                #expect(store[key1] == testValue)
                #expect(store[key1] == store[key2])
                store.removeEntry(for: key2)
                #expect(!store.hasEntry(for: key1))
                #expect(!store.hasEntry(for: key2))
                #expect(store[key1] == nil)
                #expect(store[key1] == store[key2])
            }
            
            store[key2] = nil
            #expect(!store.hasEntry(for: key1))
            #expect(!store.hasEntry(for: key2))
            #expect(store[key1] == nil)
            #expect(store[key1] == store[key2])
        }
        
        struct IntID: RawRepresentable, Equatable {
            let rawValue: Int
        }
        struct StringID: RawRepresentable, Equatable {
            let rawValue: String
        }
        
        try imp(
            IntID.self,
            testValues: [IntID(rawValue: 1), nil, IntID(rawValue: 2), nil, IntID(rawValue: 3)]
        )
        try imp(
            StringID.self,
            testValues: [StringID(rawValue: "a"), nil, StringID(rawValue: "b"), nil, StringID(rawValue: "c")]
        )
    }
    
    
    @Test
    func codableTypes() throws {
        func imp<T: Codable & Equatable & Sendable & SendableMetatype>(
            _: T.Type,
            defaultValue: T,
            testValues: [T]
        ) throws {
            let key = LocalPreferenceKey<T>("codableTest", default: defaultValue)
            store.removeEntry(for: key)
            #expect(store[key] == defaultValue)
            
            for testValue in testValues {
                store[key] = testValue
                #expect(store[key] == testValue)
                #expect(suite.object(forKey: key.key.value) is Data)
            }
        }
        
        struct Cat: Hashable, Codable {
            let name: String
            let age: Int
        }
        
        try imp(
            Cat.self,
            defaultValue: Cat(name: "Steve", age: 7),
            testValues: [Cat(name: "Martha", age: 5), Cat(name: "Blue", age: 9)]
        )
    }
    
    
    @Test
    func optionalCodableTypes() throws {
        func imp<T: Codable & Equatable & Sendable & SendableMetatype>(
            _: T.Type,
            testValues: [T?]
        ) throws {
            let key = LocalPreferenceKey<T?>("codableTest")
            store.removeEntry(for: key)
            #expect(store[key] == nil)
            
            for testValue in testValues {
                store[key] = testValue
                #expect(store[key] == testValue)
                if testValue == nil {
                    #expect(suite.object(forKey: key.key.value) == nil)
                } else {
                    #expect(suite.object(forKey: key.key.value) is Data)
                }
            }
        }
        
        struct Cat: Hashable, Codable {
            let name: String
            let age: Int
        }
        
        try imp(
            Cat.self,
            testValues: [Cat(name: "Martha", age: 5), nil, Cat(name: "Blue", age: 9), nil, Cat(name: "Sōren", age: 110)]
        )
    }
    
    
    // MARK: Migration Testing
    
    private func withTemporarySuiteForMigration(
        _ test: (_ store: LocalPreferencesStore) throws -> Void
    ) throws {
        let suiteName = "edu.stanford.SpeziViews.unitTests.migrationTesting.\(UUID().uuidString)"
        defer {
            UserDefaults.standard.removePersistentDomain(forName: suiteName)
        }
        let suite = try #require(UserDefaults(suiteName: suiteName))
        let store = LocalPreferencesStore(defaults: suite)
        try test(store)
    }
    
    
    @Test
    func migrateName() throws {
        try withTemporarySuiteForMigration { store in
            let oldKey = LocalPreferenceKey<Date>("dateOfBrith", default: Date(timeIntervalSince1970: 0))
            let newKey = LocalPreferenceKey<Date>("dateOfBirth", default: Date(timeIntervalSince1970: 0))
            let now = Date()
            #expect(!store.hasEntry(for: oldKey))
            #expect(!store.hasEntry(for: newKey))
            store[oldKey] = now
            #expect(store[oldKey] == now)
            #expect(!store.hasEntry(for: newKey))
            let migration = LocalPreferencesStore.MigrateName(from: oldKey.key, to: newKey.key)
            try store.runMigrations(migration)
            #expect(!store.hasEntry(for: oldKey))
            #expect(store[newKey] == now)
            
            // also test that we can run the migration as many times as we want and we'll always get the same result (ie the opertaion is idempotent)
            for _ in 0..<20 {
                let valueA = oldKey.read(in: store.defaults)
                let valueB = newKey.read(in: store.defaults)
                try store.runMigrations(migration)
                #expect(oldKey.read(in: store.defaults) == valueA)
                #expect(newKey.read(in: store.defaults) == valueB)
            }
        }
    }
    
    
    @Test
    func migrateType() throws {
        try withTemporarySuiteForMigration { store in
            struct Wrapped<T: Codable & Equatable>: Codable, Equatable {
                let value: T
            }
            let oldKey = LocalPreferenceKey<Wrapped<Int>>("number", default: .init(value: 0))
            let newKey = LocalPreferenceKey<Wrapped<String>>("number", default: .init(value: "zero"))
            #expect(!store.hasEntry(for: oldKey))
            #expect(!store.hasEntry(for: newKey))
            store[oldKey] = .init(value: 2)
            #expect(oldKey.read(in: store.defaults).value?.value == 2)
            #expect(newKey.read(in: store.defaults).error != nil)
            let migration = LocalPreferencesStore.MigrateValue(from: oldKey, to: newKey) { (value: Wrapped<Int>) in
                let fmt = NumberFormatter()
                fmt.numberStyle = .spellOut
                return try Wrapped(value: #require(fmt.string(from: NSNumber(value: value.value))))
            }
            try store.runMigrations(migration)
            #expect(store[newKey].value == "two")
            #expect(oldKey.read(in: store.defaults).error != nil)
            
            // also test that we can run the migration as many times as we want and we'll always get the same result (ie the opertaion is idempotent)
            for idx in 0..<20 {
                let valueA = oldKey.read(in: store.defaults)
                let valueB = newKey.read(in: store.defaults)
                #expect(valueA.error != nil)
                #expect(valueB == .value(.init(value: "two")))
                try store.runMigrations(migration)
                #expect(oldKey.read(in: store.defaults) == valueA, "\(idx)")
                #expect(newKey.read(in: store.defaults) == valueB, "\(idx)")
            }
        }
    }
}


extension LocalPreferenceKeys {
    fileprivate static let string = LocalPreferenceKey<String>(
        .init("string", in: .custom("edu.stanford.SpeziViews.unitTests")),
        default: ""
    )
    fileprivate static let stringOpt = LocalPreferenceKey<String?>(
        .init("stringOpt", in: .custom("edu.stanford.SpeziViews.unitTests")),
        default: nil
    )
}


// MARK: Utils

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
    public static func == (lhs: Self, rhs: Self) -> Bool {
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

extension AnyOptional {
    var isNone: Bool {
        switch self.unwrappedOptional {
        case .none: true
        case .some: false
        }
    }
}
