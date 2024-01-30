//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Access the alignment of a dynamic layout component.
/// // TODO: demonstrate how to access it via preference keys
public enum Alignment { // TODO: better name? (topics docc section)
    /// The layout is horizontal.
    case horizontal
    /// The layout is vertical.
    case vertical
}


/// Dynamically layout horizontal content based on dynamic type sizes and size classes.
///
/// // TODO: how to use! pics?
///
///
/// ## Topics
///
/// ### Accessing the Alignment
/// - ``Alignment``
public struct DynamicHStack<Content: View>: View {
    private let realignAfter: DynamicTypeSize
    private let horizontalAlignment: VerticalAlignment
    private let verticalAlignment: HorizontalAlignment
    private let spacing: CGFloat?
    private let content: Content

    @Environment(\.dynamicTypeSize)
    private var dynamicTypeSize
    @Environment(\.horizontalSizeClass)
    private var horizontalSizeClass // for iPad or landscape we want to stay horizontal

    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation


    public var body: some View {
        ZStack {
            if horizontalSizeClass == .regular || orientation.isLandscape || dynamicTypeSize <= realignAfter {
                HStack(alignment: horizontalAlignment, spacing: spacing) {
                    content
                }
                .preference(key: Alignment.self, value: .horizontal)
            } else {
                VStack(alignment: verticalAlignment, spacing: spacing) {
                    content
                }
                .preference(key: Alignment.self, value: .vertical)
            }
        }
            .observeOrientationChanges($orientation)
    }


    // TODO: docs!
    public init(
        realignAfter: DynamicTypeSize = .xxLarge,
        horizontalAlignment: VerticalAlignment = .center,
        verticalAlignment: HorizontalAlignment = .center,
        spacing: CGFloat? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.realignAfter = realignAfter
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.spacing = spacing
        self.content = content()
    }
}


extension Alignment: PreferenceKey {
    public typealias Value = Self?

    public static func reduce(value: inout Self?, nextValue: () -> Self?) {
        if let nextValue = nextValue() {
            value = nextValue
        }
    }
}


#if DEBUG
#Preview {
    List {
        DynamicHStack(verticalAlignment: .leading) {
            Text("Hello World")
            Text("How are you")
                .foregroundColor(.secondary)
        }
    }
}
#endif
