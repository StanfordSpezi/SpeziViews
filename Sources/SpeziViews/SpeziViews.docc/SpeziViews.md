# ``SpeziViews``

A Spezi framework that provides a common set of SwiftUI views and related functionality used across the Spezi ecosystem.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->
## Overview

SpeziViews provides easy-to-use and easily-reusable UI components that makes the everyday life of developing Spezi applications easier.

### Getting Started

The SpeziViews framework provides three main modules:

- **SpeziViews**: Core UI components, view state management, buttons, layouts, and navigation
- **SpeziPersonalInfo**: Components for handling personal information like name fields  
- **SpeziValidation**: Input validation with visual feedback

### Basic Usage Example

Here's a simple example showing how to use ``ViewState`` with ``AsyncButton`` to handle async operations:

```swift
import SpeziViews
import SwiftUI

struct ExampleView: View {
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        VStack {
            AsyncButton("Perform Action", state: $viewState) {
                try await performAsyncOperation()
            }
        }
        .viewStateAlert(state: $viewState)
    }
    
    private func performAsyncOperation() async throws {
        // Your async logic here
        try await Task.sleep(for: .seconds(1))
    }
}
```

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

Create card-like layouts with ``SimpleTile``:

```swift
SimpleTile(alignment: .leading) {
    TileHeader(alignment: .leading) {
        Image(systemName: "book.fill")
            .foregroundStyle(.blue)
            .font(.largeTitle)
    } title: {
        Text("Book Title")
    } subheadline: {
        Text("Author Name")
    }
} body: {
    Text("Book description goes here...")
} footer: {
    Button("Read More") { }
        .buttonStyle(.borderedProminent)
}
```

Use ``ListRow`` for enhanced list styling:

```swift
List {
    ListHeader("Settings") {
        Text("App configuration")
    }
    
    ListRow("Notifications") {
        Image(systemName: "bell")
    } action: {
        // Handle tap
    }
}
```

- ``SimpleTile``
- ``TileHeader``
- ``CompletedTileHeader``
- ``DynamicHStack``
- ``ListRow``
- ``DescriptionGridRow``
- ``ListHeader``

### Controls

Use ``AsyncButton`` for async operations with built-in loading states:

```swift
@State private var viewState: ViewState = .idle

AsyncButton("Download", state: $viewState) {
    try await downloadData()
}
.asyncButtonProcessingStyle(.listRow)
```

Create specialized pickers with ``CaseIterablePicker`` and ``OptionSetPicker``:

```swift
enum Priority: String, CaseIterable, PickerValue {
    case low = "Low"
    case high = "High"
}

@State private var priority: Priority = .low
CaseIterablePicker("Priority", selection: $priority)
```

Share content easily with the share sheet:

```swift
@State private var itemToShare: ShareSheetInput?

Button("Share") {
    itemToShare = ShareSheetInput("Hello World!")
}
.shareSheet(item: $itemToShare)
```

- ``AsyncButton``
- ``SwiftUICore/EnvironmentValues/processingDebounceDuration``
- ``SwiftUICore/View/asyncButtonProcessingStyle(_:)``
- ``CanvasView``
- ``InfoButton``
- ``DismissButton``
- ``CaseIterablePicker``
- ``OptionSetPicker``
- ``SwiftUICore/View/shareSheet(item:)``
- ``SwiftUICore/View/shareSheet(items:)``

### Managed Navigation

Create step-by-step navigation flows with ``ManagedNavigationStack``:

```swift
@State private var path = ManagedNavigationStack.Path()

ManagedNavigationStack(path: path) {
    WelcomeStep()
    ProfileStep()
    CompletionStep()
}

// In each step view:
struct WelcomeStep: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        VStack {
            Text("Welcome!")
            Button("Continue") {
                path.nextStep()
            }
        }
    }
}
```

- ``ManagedNavigationStack``
- ``ManagedNavigationStack/Path``

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

### Animations and Visual Effects

- ``SwiftUICore/View/shimmer(repeatInterval:)``
- ``SwiftUICore/View/skeletonLoading(replicationCount:repeatInterval:spacing:)``

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
