//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension View {
    /// Applies a `glass` button style to the view, if available.
    ///
    /// If the glass button style is not available, e.g. because the app is running on a pre-iOS 26 device,
    /// the modifier will either apply the `fallback` style (if available), or not do anything.
    ///
    /// - parameter fallback: The button style to apply if Liquid Glass is not available. Defaults to the [`automatic`](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/automatic) button style.
    @ViewBuilder
    public func buttonStyleGlass(
        fallback: (some PrimitiveButtonStyle)? = DefaultButtonStyle.automatic
    ) -> some View {
        #if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26, macOS 26, macCatalyst 26, tvOS 26, watchOS 26, *) {
            self.buttonStyle(.glass)
        } else if let fallback {
            self.buttonStyle(fallback)
        } else {
            self
        }
        #else
        if let fallback {
            self.buttonStyle(fallback)
        } else {
            self
        }
        #endif
    }
    
    /// Applies a `glass` button style to the view, if available.
    ///
    /// If the glass button style is not available, e.g. because the app is running on a pre-iOS 26 device,
    /// the modifier will either apply the `fallback` style (if available), or not do anything.
    ///
    /// - parameter fallback: The button style to apply if Liquid Glass is not available. Defaults to the [`borderedProminent`](https://developer.apple.com/documentation/swiftui/primitivebuttonstyle/borderedprominent) button style.
    @ViewBuilder
    public func buttonStyleGlassProminent(
        fallback: (some PrimitiveButtonStyle)? = BorderedProminentButtonStyle.borderedProminent
    ) -> some View {
        #if swift(>=6.2) && !os(visionOS)
        if #available(iOS 26, macOS 26, macCatalyst 26, tvOS 26, watchOS 26, *) {
            self.buttonStyle(.glassProminent)
        } else if let fallback {
            self.buttonStyle(fallback)
        } else {
            self
        }
        #else
        if let fallback {
            self.buttonStyle(fallback)
        } else {
            self
        }
        #endif
    }
}
