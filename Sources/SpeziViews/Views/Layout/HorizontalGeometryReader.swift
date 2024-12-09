//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Enables outer views to get access to the current width calculated by the ``HorizontalGeometryReader``
/// using the SwiftUI preference mechanisms.
public struct WidthPreferenceKey: PreferenceKey, Equatable {
    public static let defaultValue: CGFloat = 0
    
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { }
}


/// Read the width of a view.
///
/// An `HorizontalGeometryReader` enables a closure parameter-based and preference-based mechanism to read out the width of a specific view.
/// Refer to ``WidthPreferenceKey`` for using the SwiftUI preference mechanism-based system or the ``HorizontalGeometryReader/init(content:)`` initializer
/// for the closure-based approach.
public struct HorizontalGeometryReader<Content: View>: View {
    private var content: (CGFloat) -> Content
    @State private var width: CGFloat = 0
    
    
    public var body: some View {
        content(width)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                // The `onPreferenceChange` view modfier now takes a `@Sendable` closure, therefore we cannot capture `@MainActor` isolated properties
                // on the `View` directly anymore: https://developer.apple.com/documentation/swiftui/view/onpreferencechange(_:perform:)?changes=latest_minor
                // However, as the `@Sendable` closure is still run on the MainActor (at least in my testing on 18.2 RC SDKs), we can use `MainActor.assumeIsolated`
                // to avoid scheduling a `MainActor` `Task`, which could delay execution and cause unexpected UI behavior.
                MainActor.assumeIsolated {
                    self.width = width
                }
            }
    }
    
    
    /// Creates a new instance of the ``HorizontalGeometryReader``.
    /// - Parameter content: The content closure that gets the calculated width as a parameter.
    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }
}
