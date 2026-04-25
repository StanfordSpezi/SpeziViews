//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


extension InformationListView {
    /// A block of content within an `InformationListView`
    ///
    /// ## Topics
    /// ### Initializers
    /// - ``init(iconSymbol:title:description:)-(_,LocalizedStringResource,_)``
    /// - ``init(iconSymbol:title:description:)-(_,StringProtocol,_)``
    /// - ``init(icon:title:description:)-(_,LocalizedStringResource,_)``
    /// - ``init(icon:title:description:)-(_,StringProtocol,_)``
    /// - ``init(icon:title:description:)-(_,()->Text,_)``
    public struct Item {
        let icon: AnyView
        let title: Text
        let description: Text

        /// Creates a new item, using custom icon, title, and description views.
        ///
        /// - parameter icon: The item's icon, displayed at its left edge.
        /// - parameter title: The item's title, displayed to the right of the `icon`.
        /// - parameter description: The item's description, displayed below its `title`.
        public init(
            @ViewBuilder icon: () -> some View,
            @ViewBuilder title: () -> Text,
            @ViewBuilder description: () -> Text
        ) {
            self.icon = AnyView(icon())
            self.title = title()
            self.description = description()
        }
    }
}


extension InformationListView.Item {
    /// Creates a new item, using a custom icon view and localized string contents.
    ///
    /// - parameter icon: The item's icon, displayed at its left edge.
    /// - parameter title: The item's localized title, displayed to the right of the `icon`.
    /// - parameter description: The item's localized description, displayed below its `title`.
    public init(@ViewBuilder icon: () -> some View, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init {
            icon()
        } title: {
            Text(title)
        } description: {
            Text(description)
        }
    }

    /// Creates a new item, using a custom icon view and non-localized string contents.
    ///
    /// - parameter icon: The item's icon, displayed at its left edge.
    /// - parameter title: The item's localized title, displayed to the right of the `icon`.
    /// - parameter description: The item's localized description, displayed below its `title`.
    @_disfavoredOverload
    public init(@ViewBuilder icon: () -> some View, title: some StringProtocol, description: some StringProtocol) {
        self.init {
            icon()
        } title: {
            Text(title)
        } description: {
            Text(description)
        }
    }

    /// Creates a new item, using a system symbol icon and localized string contents.
    ///
    /// - parameter iconSymbol: SF Symbol name to be used as the item's icon.
    /// - parameter title: The item's localized title, displayed to the right of the `icon`.
    /// - parameter description: The item's localized description, displayed below its `title`.
    public init(iconSymbol: String, title: LocalizedStringResource, description: LocalizedStringResource) {
        self.init(icon: { Image(systemName: iconSymbol) }, title: title, description: description)
    }

    /// Creates a new item, using a system symbol icon and non-localized string contents.
    ///
    /// - parameter iconSymbol: SF Symbol name to be used as the item's icon.
    /// - parameter title: The item's title, displayed to the right of the `icon`.
    /// - parameter description: The item's description, displayed below its `title`.
    @_disfavoredOverload
    public init(iconSymbol: String, title: some StringProtocol, description: some StringProtocol) {
        self.init(icon: { Image(systemName: iconSymbol) }, title: title, description: description)
    }
}
