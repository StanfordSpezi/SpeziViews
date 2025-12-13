//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order all

import Foundation
import SpeziFoundation
import SwiftUI


/// A type-safe alternative to SwiftUI's `AppStorage`.
///
///
/// The `@LocalPreference` property wrapper accesses the key's corresponding value in the `UserDefaults`.
/// This property wrapper is auto-updating.
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
/// extension LocalPreferenceKeys {
///     static let rootTab = LocalPreferenceKey<RootTab>("rootTab", default: .home)
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
//@MainActor
@propertyWrapper
public struct LocalPreference<T: SendableMetatype>: DynamicProperty, Sendable {
    private let key: LocalPreferenceKey<T>
    private let store: LocalPreferencesStore
    @State private var observer = UserDefaultsKeyObserver<T>()
    
    /// The current value of the local preference..
    public var wrappedValue: T {
        get {
            _ = observer.viewUpdate
            return store[key]
        }
        nonmutating set {
            store[key] = newValue
        }
    }
    
    /// A `Binding` that provides read-write access to the value.
    public var projectedValue: Binding<T> {
        _ = observer.viewUpdate
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
        observer.configure(for: key, in: store)
    }
}


/// `ObservableObject` that publishes a change whenever the specified key in the specified defaults store changes.
@Observable
private final class UserDefaultsKeyObserver<T: SendableMetatype>: NSObject, Sendable {
    private struct State {
        struct Config: Hashable {
            let key: LocalPreferenceKey<T>
            let store: LocalPreferencesStore
        }
        enum ObservationInfo {
            case kvo
            case notifications(_ token: any NSObjectProtocol)
            var isKvo: Bool {
                switch self {
                case .kvo: true
                case .notifications: false
                }
            }
        }
        let config: Config
        let observation: ObservationInfo
    }
    
    let lock = RWLock()
    @ObservationIgnored nonisolated(unsafe) private var state: State?
    // https://github.com/swiftlang/swift/issues/81962
    nonisolated(unsafe) private(set) var viewUpdate: UInt64 = 0
    // only used if observing via KVO
    @ObservationIgnored nonisolated(unsafe) private var lastSeenValue: T?
    
    nonisolated override init() {
        super.init()
    }
    
    func configure(for key: LocalPreferenceKey<T>, in store: LocalPreferencesStore) {
        let newConfig = State.Config(key: key, store: store)
        guard newConfig != state?.config else {
            return
        }
        stop()
        assert(state == nil)
        assert(lastSeenValue == nil)
        if key.key.isKVOCompatible {
            store.defaults.addObserver(self, forKeyPath: key.key.value, options: [], context: nil)
            state = .init(config: newConfig, observation: .kvo)
        } else {
            let token = NotificationCenter.default.addObserver(
                forName: UserDefaults.didChangeNotification,
                object: store.defaults,
                queue: nil
            ) { [weak self] _ in
                guard let self else {
                    return
                }
                self.lock.withWriteLock {
                    self.handleNCUpdate()
                }
            }
            state = .init(config: newConfig, observation: .notifications(token))
        }
    }
    
    // swiftlint:disable:next block_based_kvo discouraged_optional_collection
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        lock.withWriteLock {
            guard let state, state.observation.isKvo, state.config.key.key.value == keyPath,
                  state.config.store.defaults == (object as? UserDefaults) else {
                super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                return
            }
            viewUpdate &+= 1
        }
    }
    
    private func handleNCUpdate() {
        guard let state else {
            return
        }
        let newValue = state.config.store[state.config.key]
        defer {
            lastSeenValue = newValue
        }
        // T.self is any Equatable.Type
        guard let oldValue = lastSeenValue else {
            viewUpdate &+= 1
            return
        }
        precondition(((newValue as? any Equatable) != nil) == (T.self is any Equatable.Type))
        if let newValue = newValue as? any Equatable {
            guard !newValue.isEqual(to: oldValue) else {
                // the value is unchanged
                return
            }
            // the value did actually change
            viewUpdate &+= 1
        } else {
            // the value is not Equatable, so we need to just assume that it changed (even though it might not have...)
            viewUpdate &+= 1
        }
    }
    
    private func stop() {
        lastSeenValue = nil
        guard let state else {
            return
        }
        switch state.observation {
        case .kvo:
            state.config.store.defaults.removeObserver(self, forKeyPath: state.config.key.key.value)
        case .notifications(let token):
            NotificationCenter.default.removeObserver(token)
        }
        self.state = nil
    }
    
    deinit {
        // one small annoyance here is that @State objects don't necessarily get deallocated right away when the view that's owning them
        // gets dismissed. it seems that some SwiftUI view elements keep previously-presented-but-now-dismissed views in memory for a while,
        // and it seems that there's nothing we can do about that.
        stop()
    }
}
