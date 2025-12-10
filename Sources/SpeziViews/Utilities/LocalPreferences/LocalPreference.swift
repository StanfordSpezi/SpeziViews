//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import SwiftUI


/// A type-safe alternative to SwiftUI's `AppStorage`.
///
///
/// The `@LocalPreference` property wrapper accesses the key's corresponding value in the `UserDefaults`.
///
/// By default, the ``LocalPreferencesStore/standard`` `UserDefaults` store is used, but you can customise this (see ``init(_:store:)``).
///
/// Similar to `@State` and `@AppStorage`, you can use the `$`-prefix notation to obtain a `Binding` to the value.
///
/// ```swift
/// enum RootTab: String {
///     case home, feed, account
/// }
///
/// extension LocalPreferenceKey {
///     static var rootTab: LocalPreferenceKey<RootTab> {
///         .make("rootTab", default: .home)
///     }
/// }
///
///
/// struct RootView: View {
///     @LocalPreference(.rootTab) private var selectedTab
///
///     var body: some View {
///         TabView(selection: $selectedTab) {
///             Tab(value: .home) {
///                 // ...
///             }
///             Tab(value: .feed) {
///                 // ...
///             }
///             Tab(value: .account) {
///                 // ...
///             }
///         }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Initializers
/// - ``init(_:)``
/// - ``init(_:store:)``
///
/// ## Instance Properties
/// - ``wrappedValue``
/// - ``projectedValue``
@MainActor
@propertyWrapper
public struct LocalPreference<T: SendableMetatype>: DynamicProperty {
    private let key: LocalPreferenceKey<T>
    private let store: LocalPreferencesStore
    @State private var kvoObserver = UserDefaultsKeyObserver()
    
    /// The value.
    public var wrappedValue: T {
        get {
            _ = kvoObserver.viewUpdate
            return store[key]
        }
        nonmutating set {
            store[key] = newValue
        }
    }
    
    /// A `Binding` that provides read-write access to the value.
    public var projectedValue: Binding<T> {
        _ = kvoObserver.viewUpdate
        return Binding<T> {
            store[key]
        } set: {
            store[key] = $0
        }
    }
    
    /// Creates a property for a local preference value.
    nonisolated public init(_ key: LocalPreferenceKey<T>) {
        self.init(key, store: .standard)
    }
    
    /// Creates a property for a local preference value in a custom preferences store.
    nonisolated public init(_ key: LocalPreferenceKey<T>, store: LocalPreferencesStore) {
        self.key = key
        self.store = store
    }
    
    @_documentation(visibility: internal)
    nonisolated public func update() {
        MainActor.assumeIsolated {
            kvoObserver.configure(for: key.rawValue, in: store.defaults)
        }
    }
}


/// `ObservableObject` that publishes a change whenever the specified key in the specified defaults store changes.
@Observable
private final class UserDefaultsKeyObserver: NSObject {
    private struct ObservationContext: Equatable {
        let defaults: UserDefaults
        let key: String
    }
    @ObservationIgnored private var context: ObservationContext?
    private(set) var viewUpdate: UInt64 = 0
    
    func configure(for key: String, in userDefaults: UserDefaults) {
        let newContext = ObservationContext(defaults: userDefaults, key: key)
        guard newContext != context else {
            return
        }
        stop()
        userDefaults.addObserver(self, forKeyPath: key, options: [], context: nil)
        context = newContext
    }
    
    // swiftlint:disable:next block_based_kvo discouraged_optional_collection
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if let keyPath, keyPath == self.context?.key {
            viewUpdate &+= 1
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    private func stop() {
        if let context {
            context.defaults.removeObserver(self, forKeyPath: context.key)
            self.context = nil
        }
    }
    
    deinit {
        // one small annoyance here is that @State objects don't necessarily get deallocated right away when the view that's owning them
        // gets dismissed. it seems that some SwiftUI view elements keep previously-presented-but-now-dismissed views in memory for a while,
        // and it seems that there's nothing we can do about that.
        stop()
    }
}
