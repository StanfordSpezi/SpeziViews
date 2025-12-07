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
        for key in suite.dictionaryRepresentation().keys where key.starts(with: "edu_stanford_SpeziViews_") {
            suite.removeObject(forKey: key)
        }
    }
    
    @Test
    func simpleTypes() throws {
        #expect(LocalPreferenceKey<Any>.string.key == "")
        #expect(store[.string] == "")
        #expect(store[.stringOpt] == nil)
        #expect(suite.string(forKey: "edu_stanford_MyHeartCounts_string") == nil)
        store[.string] = "abc"
        #expect(store[.string] == "abc")
        #expect(try #require(suite.string(forKey: "edu_stanford_MyHeartCounts_string")) == "abc")
    }
}


fileprivate extension LocalPreferenceKey { // swiftlint:disable:this no_extension_access_modifier
    static var string: LocalPreferenceKey<String> {
        .make("string", default: "")
    }
    
    static var stringOpt: LocalPreferenceKey<String?> {
        .make("stringOpt", default: nil)
    }
}
