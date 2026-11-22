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


### Managing View State

A ``ViewState`` describes whether a view is idle, processing, or failed with an error.
Bind it to an ``AsyncButton`` to run an asynchronous, throwing action:
the button shows a progress indicator while the action runs, and stores any thrown error in the view state.
The ``SwiftUICore/View/viewStateAlert(state:)-4wzs4`` modifier presents that error to the user in an alert.

```swift
struct SyncView: View {
    @State private var viewState: ViewState = .idle

    var body: some View {
        AsyncButton("Sync Data", state: $viewState) {
            try await sync()
        }
            .viewStateAlert(state: $viewState)
    }

    private func sync() async throws {
        // ...
    }
}
```

> Important: The task of an ``AsyncButton`` is bound to the lifetime of the button view and is cancelled when the button disappears.
    Avoid starting long-running work that must outlive the button, for example from an alert or a swipe action button.
    The ``AsyncButton`` documentation shows how to bind the task to a view higher up in the view hierarchy instead.

Use the ``OperationState`` protocol to map a more complex state machine to a ``ViewState`` and reuse the same modifiers.

### Building Multi-Step Flows

A ``ManagedNavigationStack`` builds a navigation flow, such as an onboarding, from a list of steps.
Compared to a plain `NavigationStack`, the steps don't need to know which step comes next:
you declare all steps, including conditional ones, in one place, and each step advances the flow by calling
``ManagedNavigationStack/Path/nextStep()`` on the ``ManagedNavigationStack/Path`` from the environment.

```swift
struct Onboarding: View {
    @AppStorage("didCompleteOnboarding") private var didCompleteOnboarding = false

    var body: some View {
        ManagedNavigationStack(didComplete: $didCompleteOnboarding) {
            Welcome()
            if !notificationsAuthorized {
                NotificationPermissions()
            }
            FinalStep()
        }
    }
}

struct Welcome: View {
    @Environment(ManagedNavigationStack.Path.self) private var path

    var body: some View {
        Button("Continue") {
            path.nextStep()
        }
    }
}
```

The ``ManagedNavigationStack`` documentation describes how to navigate to a specific step and how to push steps that aren't part of the declared flow.

### Sharing Content

SwiftUI's [`ShareLink`](https://developer.apple.com/documentation/swiftui/sharelink) is the preferred way to share a URL, a string, or a file.
Use the ``SwiftUICore/View/shareSheet(item:)`` modifier if you need to present the share sheet from a binding,
for example only after some processing finished, or if the `ShareLink` doesn't display the metadata of your content, as is the case for a `PDFDocument`.
Wrap the content you want to share in a ``ShareSheetInput``.

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
- ``SwiftUICore/View/asyncButtonProcessingStyle(_:)``
- ``CanvasView``
- ``InfoButton``
- ``DismissButton``
- ``CaseIterablePicker``
- ``OptionSetPicker``
- ``SwiftUICore/View/shareSheet(item:)``
- ``SwiftUICore/View/shareSheet(items:)``

### Managed Navigation

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
