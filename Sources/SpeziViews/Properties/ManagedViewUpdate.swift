//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@Observable
private final class UIUpdate {
    @MainActor private var dateTimer: Timer? {
        willSet {
            dateTimer?.invalidate()
        }
    }

    nonisolated init() {}

    @MainActor
    func scheduleUpdate(at date: Date) {
        @MainActor
        struct WeakSendingSelf: Sendable { // assumeIsolated requires a @Sendable closure, so we need to pass self via a Sendable type
            weak var value: UIUpdate?

            init(_ value: UIUpdate) {
                self.value = value
            }
        }

        let sendingSelf = WeakSendingSelf(self)

        let timer = Timer(fire: date, interval: 0, repeats: false) { [sendingSelf] _ in
            MainActor.assumeIsolated { [sendingSelf] in
                sendingSelf.value?.dateTimer = nil // triggers observable mutation
            }
        }
        RunLoop.main.add(timer, forMode: .common)

        self.dateTimer = timer // triggers observable access
    }

    deinit {
        _dateTimer?.invalidate()
    }
}


/// A property wrapper that allows to manually manage view updates for SwiftUI views.
///
/// ```swift
/// struct DueLabel: View {
///     let dueDate: Date
///
///     @ManagedViewUpdate private var viewUpdate
///
///     var body: some View {
///         if Date.now >= dueDate {
///             Text("Due")
///         } else {
///             Text("Upcoming")
///                 .onAppear {
///                     viewUpdate.schedule(at: dueDate)
///                 }
///         }
///     }
/// }
///
/// - Tip: SwiftUI provides [`TimeDataSource`](https://developer.apple.com/documentation/swiftui/timedatasource) which can be used
///     with `Text` and [`DiscreteFormatStyle`](https://developer.apple.com/documentation/foundation/discreteformatstyle)s
///     to have text formatted `Date`s that automatically re-render. The above example could be implemented by creating a custom
///     `DiscreteFormatStyle`. However, `ManagedViewUpdate` is especially handy, if other properties update on a time-dependent manner
///     (e.g., a button becoming enabled once a start date is reached).
/// ```
@propertyWrapper
public struct ManagedViewUpdate: DynamicProperty {
    private let update = UIUpdate()

    public var wrappedValue: Self {
        self
    }

    public init() {}
    
    /// Schedule a view update to occur at a specific point in time.
    /// - Parameter date: The time at which the view should be redrawn.
    @MainActor
    public func schedule(at date: Date) {
        update.scheduleUpdate(at: date)
    }
}
