//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SpeziViews
import SwiftUI


struct LocalPreferencesTests: View {
    var body: some View {
        Form {
            NavigationLink("Basic Usage") {
                BasicUsageTest()
            }
            NavigationLink("AppStorage Interop (1)") {
                InteropCounterTest(key: .interopCounter1)
            }
            NavigationLink("AppStorage Interop (2)") {
                InteropCounterTest(key: .interopCounter2)
            }
        }
    }
}


private struct BasicUsageTest: View {
    @LocalPreference(.counter)
    private var counter
    
    var body: some View {
        Form {
            Text(LocalPreferenceKey<Any>.counter.key.value)
            LabeledContent("Counter", value: counter, format: .number)
                .accessibilityIdentifier("counter1")
                .accessibilityValue(String(counter))
            AltPrefValueFetcher(.counter) { value in
                LabeledContent("Counter (alt)", value: value, format: .number)
                    .accessibilityIdentifier("counter2")
                    .accessibilityValue(String(counter))
            }
            Section {
                Button("Increment") {
                    counter += 1
                }
                Button("Decrement") {
                    counter -= 1
                }
                Button("Reset") {
                    counter = 0
                }
                Button("Reset via UserDefaults API") {
                    UserDefaults.standard.removeObject(forKey: LocalPreferenceKey<Any>.counter.key.value)
                }
            }
            Section {
                BindingBasedCounter(value: $counter)
            }
        }
        .task {
            // we need to reset this before every run, in case the simulator still contains the previous run's state.
            counter = 0
        }
    }
}


extension BasicUsageTest {
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


private struct InteropCounterTest: View {
    @LocalPreference<Int> var counterA: Int
    @AppStorage<Int> var counterB: Int
    
    var body: some View {
        Form {
            Section {
                LabeledContent("Counter A", value: counterA, format: .number)
                    .accessibilityIdentifier("counterA")
                    .accessibilityValue(String(counterA))
                LabeledContent("Counter B", value: counterB, format: .number)
                    .accessibilityIdentifier("counterB")
                    .accessibilityValue(String(counterB))
            }
            Section {
                Button("Increment Counter A") {
                    counterA += 1
                }
                Button("Increment Counter B") {
                    counterA += 1
                }
            }
            Section {
                Button("Decrement Counter A") {
                    counterA -= 1
                }
                Button("Decrement Counter B") {
                    counterA -= 1
                }
            }
            Section {
                Button("Reset Counter A") {
                    counterA = 0
                }
                Button("Reset Counter B") {
                    counterA = 0
                }
            }
        }
    }
    
    init(key: LocalPreferenceKey<Int>) {
        _counterA = .init(key)
        _counterB = .init(wrappedValue: 0, key.key.value)
    }
}


extension LocalPreferenceKeys {
    fileprivate static let counter = LocalPreferenceKey<Int>("counter.2", default: 0)
    
    fileprivate static let interopCounter1 = LocalPreferenceKey<Int>(.init("interopCounter1", in: .none), default: 0)
    fileprivate static let interopCounter2 = LocalPreferenceKey<Int>(.init(verbatim: "interop.Counter.2", in: .none), default: 0)
}
