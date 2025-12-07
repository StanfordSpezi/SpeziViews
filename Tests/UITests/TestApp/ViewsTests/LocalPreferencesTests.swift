//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


enum RootTab: String {
    case home, feed, account
}


struct RootView: View {
    @LocalPreference(.rootTab) private var selectedTab
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: .home) {
                // ...
            }
            Tab(value: .feed) {
                // ...
            }
            Tab(value: .account) {
                // ...
            }
        }
    }
}


extension LocalPreferenceKey {
    static var rootTab: LocalPreferenceKey<RootTab> {
        .make("rootTab", default: .home)
    }
}

struct LocalPreferencesTests: View {
    @LocalPreference(.counter)
    private var counter
    
    var body: some View {
        Form {
            Text(LocalPreferenceKey<Any>.counter.rawValue)
            LabeledContent("Counter", value: counter, format: .number)
                .accessibilityIdentifier("counter1")
                .accessibilityValue(String(counter))
            AltPrefValueFetcher(.counter) { value in
                LabeledContent("Counter (alt)", value: value, format: .number)
                    .accessibilityIdentifier("counter2")
                    .accessibilityValue(String(counter))
            }
            Section {
                Button("Decrement") {
                    counter -= 1
                }
                Button("Increment") {
                    counter += 1
                }
                Button("Reset") {
                    counter = 0
                }
                Button("Reset via UserDefaults API") {
                    UserDefaults.standard.removeObject(forKey: LocalPreferenceKey<Any>.counter.rawValue)
                }
            }
            Section {
                BindingBasedCounter(value: $counter)
            }
        }
    }
}


extension LocalPreferencesTests {
    private struct AltPrefValueFetcher<Value: SendableMetatype, Content: View>: View {
        @LocalPreference<Value> private var value: Value
        private let content: @MainActor (Value) -> Content
        
        var body: some View {
            content(value)
        }
        
        init(_ key: LocalPreferenceKey<Value>, @ViewBuilder _ content: @escaping @MainActor (Value) -> Content) {
            self._value = .init(key)
            self.content = content
        }
    }
    
    private struct BindingBasedCounter: View {
        @Binding var value: Int
        
        var body: some View {
            LabeledContent("Counter (Binding)", value: value, format: .number)
                .accessibilityIdentifier("counterBinding")
                .accessibilityValue(String(value))
            Button("Increment via Binding") {
                value += 1
            }
            Button("Decrement via Binding") {
                value -= 1
            }
            Button("Reset via Binding") {
                value = 0
            }
        }
    }
}


extension LocalPreferenceKey {
    fileprivate static var counter: LocalPreferenceKey<Int> {
        .make("counter", default: 0)
    }
}
