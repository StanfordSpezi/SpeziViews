//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


struct DeviceOrientationModifier: ViewModifier {
    @Binding private var orientation: UIDeviceOrientation

    func body(content: Content) -> some View {
        content
            .onAppear {
                orientation = UIDevice.current.orientation
            }
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }


    init(orientation: Binding<UIDeviceOrientation>) {
        self._orientation = orientation
    }
}


extension View {
    func observeOrientationChanges(_ orientation: Binding<UIDeviceOrientation>) -> some View {
        modifier(DeviceOrientationModifier(orientation: orientation))
    }
}
