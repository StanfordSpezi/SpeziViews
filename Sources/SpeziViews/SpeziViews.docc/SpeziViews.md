# ``SpeziViews``

A Spezi framework that provides a common set of SwiftUI views and related functionality used across the Spezi ecosystem.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->
## Overview

SpeziViews provides easy-to-use and easily-reusable UI components that makes the everyday life of developing Spezi applications easier.

@Row {
    @Column {
        @Image(source: "ViewState", alt: "A SwiftUI alert displayed using the SpeziViews ViewState.") {
            Easily manage view state and display erroneous state using ``ViewState``.
        }
    }
    @Column {
        @Image(source: "NameFields", alt: "Three text fields to input your first, middle and last name.") {
            The [SpeziPersonalInfo](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezipersonalinfo)
            provides easy to use abstractions for dealing with personal information.
            For example collecting the input for multiple [`PersonNameComponents`](https://developer.apple.com/documentation/foundation/personnamecomponents)
            fields using [`NameFieldRow`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezipersonalinfo/namefieldrow).
        }
    }
    @Column {
        @Image(source: "Validation", alt: "Three different kinds of text fields showing validation errors in red text.") {
            Perform and visualize input validation with ease using [SpeziValidation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezivalidation).
        }
    }
}


## Topics

### Manage and communicate View State

- ``ViewState``
- ``SwiftUICore/View/viewStateAlert(state:)-4wzs4``
- ``SwiftUICore/View/viewStateAlert(state:)-27a86``
- ``OperationState``
- ``SwiftUICore/View/map(state:to:)``
- ``SwiftUICore/View/processingOverlay(isProcessing:overlay:)-5xplv``
- ``SwiftUICore/View/processingOverlay(isProcessing:overlay:)-3df8d``

### Layout
Default layouts and utilities to automatically adapt your view layouts to dynamic type sizes, device orientation, and device size classes.

- ``SimpleTile``
- ``TileHeader``
- ``CompletedTileHeader``
- ``DynamicHStack``
- ``ListRow``
- ``DescriptionGridRow``
- ``ListHeader``

### Controls

- ``AsyncButton``
- ``SwiftUICore/EnvironmentValues/processingDebounceDuration``
- ``CanvasView``
- ``InfoButton``
- ``DismissButton``
- ``CaseIterablePicker``
- ``OptionSetPicker``

### Displaying Text

- ``Label``
- ``LazyText``
- ``MarkdownView``
- ``TextContentType``

### Images

- ``ImageReference``

### Conditional Modifiers

- ``SwiftUICore/View/if(_:transform:)``
- ``SwiftUICore/View/if(condition:transform:)``

### Interact with the View Environment

- ``SwiftUICore/View/focusOnTap()``
- ``SwiftUICore/View/observeOrientationChanges(_:)``

### View Management

- ``ManagedViewUpdate``

### Styles

- ``ReverseLabelStyle``
- ``SwiftUI/LabelStyle/reverse``

### Localization

- ``Foundation/LocalizedStringResource/BundleDescription/atURL(from:)``
- ``Foundation/LocalizedStringResource/localizedString(for:)``
- ``Swift/StringProtocol/localized(_:)``

### Readers

- ``HorizontalGeometryReader``
- ``WidthPreferenceKey``

### Error Handling

- ``AnyLocalizedError``
- ``SwiftUICore/EnvironmentValues/defaultErrorDescription``

### Modules

- ``ConfigureTipKit``

### System Programming Interfaces
- <doc:SPI>
