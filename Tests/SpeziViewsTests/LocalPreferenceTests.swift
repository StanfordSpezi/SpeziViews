//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable empty_string

import Foundation
@testable import SpeziViews
import Testing


@Suite
final class LocalPreferenceTests {
    let suite: UserDefaults
    let store: LocalPreferencesStore
    
    init() throws {
        suite = try #require(UserDefaults(suiteName: "edu.stanford.SpeziViews.unitTests"))
        store = LocalPreferencesStore(defaults: suite)
    }
    
    deinit { // swiftlint:disable:this type_contents_order
        for key in suite.dictionaryRepresentation().keys where key.starts(with: "edu_stanford_SpeziViews_unitTests") {
            suite.removeObject(forKey: key)
        }
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
        let key = "_bool1"
        #expect(!suite.bool(forKey: key))
        suite.set(true, forKey: key)
        #expect(suite.bool(forKey: key))
        
        suite.set("true", forKey: key)
        #expect(suite.bool(forKey: key))
        
        suite.set("false", forKey: key)
        #expect(!suite.bool(forKey: key))
        
        suite.set("abc", forKey: key)
        #expect(!suite.bool(forKey: key))
        
        suite.set("123", forKey: key)
        #expect(!suite.bool(forKey: key))
        
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
