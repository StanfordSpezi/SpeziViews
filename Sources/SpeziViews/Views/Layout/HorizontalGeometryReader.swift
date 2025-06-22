//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziFoundation
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

    @State private var values = AsyncStream.makeStream(of: CGFloat.self)

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
                if Thread.isMainThread {
                    MainActor.assumeIsolated {
                        self.width = width
                    }
                } else {
                    values.continuation.yield(width)
                }
            }
            .task {
                for await value in values.stream {
                    self.width = value
                }
                values = AsyncStream.makeStream()
            }
    }
    
    
    /// Creates a new instance of the ``HorizontalGeometryReader``.
    /// - Parameter content: The content closure that gets the calculated width as a parameter.
    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }
}
