//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


@available(visionOS, unavailable)
@available(tvOS, unavailable)
@available(macOS, unavailable)
struct DeviceOrientationModifier: ViewModifier {
    @Binding private var orientation: UIDeviceOrientation


    init(orientation: Binding<UIDeviceOrientation>) {
        self._orientation = orientation
    }


    func body(content: Content) -> some View {
        content
            .onAppear {
                orientation = UIDevice.current.orientation
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }
}


extension View {
    /// Observe changes to the device orientation.
    ///
    /// Use this modifier to observe changes to the current device orientation.
    ///
    /// ```swift
    /// struct MyView: View {
    ///     @State private var orientation = UIDevice.current.orientation
    ///
    ///     var body: some View {
    ///         List {
    ///             // ...
    ///         }
    ///             .observeOrientationChanges($orientation)
    ///     }
    /// }
    /// ```
    ///
    ///
    /// - Parameter orientation: The Binding to your `UIDeviceOrientation` state.
    /// - Returns: The modified view that observes device orientation.
    @available(visionOS, unavailable)
    @available(tvOS, unavailable)
    public func observeOrientationChanges(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DeviceOrientationModifier(orientation: orientation))
    }
}
