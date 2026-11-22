# ``SpeziPersonalInfo``

A SpeziViews target that provides a common set of SwiftUI views and related functionality for managing personal information.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

SpeziPersonalInfo provides predefined UI components to deal with common cases in visualizing or collecting personal information.

@Column {
    @Image(source: "NameFields", alt: "Three text fields to input your first, middle and last name.") {
        Collect the input for multiple [`PersonNameComponents`](https://developer.apple.com/documentation/foundation/personnamecomponents)
        fields using [`NameFieldRow`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezipersonalinfo/namefieldrow).
    }
}

### Collecting a Name

Place ``NameFieldRow``s into a [`Grid`](https://developer.apple.com/documentation/swiftui/grid) to show a description in front of each text field.
Each field edits one component of a [`PersonNameComponents`](https://developer.apple.com/documentation/foundation/personnamecomponents) value
and sets the matching text content type, so that the system can offer AutoFill suggestions.

```swift
@State private var name = PersonNameComponents()

var body: some View {
    Form {
        Grid(horizontalSpacing: 15) {
            NameFieldRow("First", name: $name, for: \.givenName) {
                Text("enter first name")
            }

            Divider()
                .gridCellUnsizedAxes(.horizontal)

            NameFieldRow("Last", name: $name, for: \.familyName) {
                Text("enter last name")
            }
        }
    }
}
```

Use a ``NameTextField`` if you don't need a description in front of the text field.

### Displaying a Profile

A ``UserProfileView`` displays a person's profile image in a circle.
It shows the initials of the person's name while the image loads, or if no image is available.

```swift
UserProfileView(name: name) {
    await loadProfileImage()
}
    .frame(width: 60, height: 60)
```

## Topics

### Person Name

- ``NameTextField``
- ``NameFieldRow``

### User Profile

- ``UserProfileView``
