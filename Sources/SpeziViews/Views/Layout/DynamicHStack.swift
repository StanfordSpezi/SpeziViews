//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Access the dynamic layout of a child view.
///
/// Refer to the documentation of ``DynamicHStack`` on how to retrieve the current layout.
public enum DynamicLayout {
    /// The layout is horizontal.
    case horizontal
    /// The layout is vertical.
    case vertical
}


/// Dynamically layout horizontal content based on dynamic type sizes, device orientation, and size classes.
///
/// This dynamic `HStack` automatically transform its row-based content to wrap around the next line
/// in circumstances where there isn't enough vertical screen space available.
/// It accommodates for dynamic type sizes, device orientation and device size classes.
///
/// The `HStack` automatically transform into a `VStack` if the content is considered too wide.
/// This check is done based on the [`dynamicTypeSize`](https://developer.apple.com/documentation/swiftui/environmentvalues/dynamictypesize)
/// of the view. This check won't apply if the [`horizontalSizeClass`](https://developer.apple.com/documentation/swiftui/environmentvalues/horizontalsizeclass)
/// is `regular` (not `compact`) or if the device is in landscape orientation (refer to [`UIDeviceOrientation`](https://developer.apple.com/documentation/uikit/uideviceorientation)).
///
/// ### Checking the current layout
///
/// You can retrieve the current `DynamicHStack` layout using the ``DynamicLayout`` preference key.
/// This is useful if you want to conditionally change the layout of your View depending on the current
/// layout of your content (e.g., only render a `Spacer` if the view is horizontally aligned).
/// You can retrieve the current layout using the [`onPreferenceChange(_:perform:)`](https://developer.apple.com/documentation/swiftui/view/onpreferencechange(_:perform:))
/// modifier.
///
/// Below is a short code example that demonstrates this capability.
///
/// - Tip: The ``ListRow`` view might be helpful for scenarios like the one below, where you want to show
///     a value for a specific element within a `List`. It deals covers additional text layout properties
///     to make sure your view looks good in any dynamic type size.
///
/// ```swift
/// /// Display the current temperature for a city.
/// struct TemperatureRow: View {
///     private let city: LocalizedStringResource
///     private let temperature: Int
///
///     @State var currentLayout: DynamicLayout?
///
///     var body: some View {
///         DynamicHStack {
///             Text(city)
///
///             if currentLayout == .horizontal {
///                 Spacer()
///             }
///
///             Text(verbatim: "\(temperature) °C")
///                 .foregroundColor(.secondary)
///         }
///             .onPreferenceChange(DynamicLayout.self) { layout in
///                 currentLayout = layout
///             }
///     }
/// }
/// ```
///
/// ## Topics
///
/// ### Checking the current layout
/// - ``DynamicLayout``
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

    @State private var orientation = UIDevice.current.orientation


    public var body: some View {
        ZStack {
            if horizontalSizeClass == .regular || orientation.isLandscape || dynamicTypeSize <= realignAfter {
                HStack(alignment: horizontalAlignment, spacing: spacing) {
                    content
                }
                    .preference(key: DynamicLayout.self, value: .horizontal)
            } else {
                VStack(alignment: verticalAlignment, spacing: spacing) {
                    content
                }
                .   preference(key: DynamicLayout.self, value: .vertical)
            }
        }
            .observeOrientationChanges($orientation)
    }


    /// Create a new dynamically adjusting `HStack` for row-based content-
    /// - Parameters:
    ///   - realignAfter: The dynamic type size threshold after the view we re-layout to a `VStack`.
    ///   - horizontalAlignment: The alignment used for the `HStack`.
    ///   - verticalAlignment: The alignment used for the `VStack`.
    ///   - spacing: The spacing between elements.
    ///   - content: The content to display.
    public init(
        realignAfter: DynamicTypeSize = .xxLarge,
        horizontalAlignment: VerticalAlignment = .center,
        verticalAlignment: HorizontalAlignment = .leading,
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


extension DynamicLayout: PreferenceKey {
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
            Text(verbatim: "Hello World:")
            Text(verbatim: "How are you doing?")
                .foregroundColor(.secondary)
        }
    }
}
#endif
