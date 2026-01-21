# ``SpeziPersonalInfo``

A SpeziViews target that provides a common set of SwiftUI views and related functionality for managing personal information.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

SpeziPersonalInfo provides predefined UI components to deal with common cases in visualizing or collecting personal information.

### Getting Started

Use ``NameFieldRow`` to create organized name input forms:

```swift
import SpeziPersonalInfo
import SwiftUI

struct ProfileView: View {
    @State private var name = PersonNameComponents()
    
    var body: some View {
        Form {
            Section("Personal Information") {
                Grid(horizontalSpacing: 15) {
                    NameFieldRow("First", name: $name, for: \.givenName) {
                        Text("Enter your first name")
                    }
                    
                    Divider()
                        .gridCellUnsizedAxes(.horizontal)
                    
                    NameFieldRow("Last", name: $name, for: \.familyName) {
                        Text("Enter your last name")
                    }
                }
            }
        }
    }
}
```

The components automatically handle proper capitalization, formatting, and accessibility for name inputs.

@Column {
    @Image(source: "NameFields", alt: "Three text fields to input your first, middle and last name.") {
        Collect the input for multiple [`PersonNameComponents`](https://developer.apple.com/documentation/foundation/personnamecomponents)
        fields using [`NameFieldRow`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/spezipersonalinfo/namefieldrow).
    }
}

## Topics

### Person Name

- ``NameTextField``
- ``NameFieldRow``

### User Profile

- ``UserProfileView``
