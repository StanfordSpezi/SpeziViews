# ``SpeziValidation``

Perform input validation and visualize it to the user.

<!--

This source file is part of the Spezi open-source project

SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT

-->

## Overview

`SpeziValidation` can be used to perform input validation on `String`-based inputs and provides easy-to-use
mechanism to communicate validation feedback back to the user.
The library is based on a rule-based approach using ``ValidationRule``s.

### Performing Validation

The only thing you have to do, is to set up the ``SwiftUI/View/validate(input:rules:)-5dac4`` modifier for your
text input.
Supply your input and validation rules.

The below code example shows a basic validation setup.
Note that we are using the ``VerifiableTextField`` to automatically visualize validation errors to the user.

```swift
@State var phrase: String = ""

var body: some View {
    Form {
        VerifiableTextField("your favorite phrase", text: $phrase)
            .validate(input: phrase, rules: .nonEmpty)
    }
}
```

> Note: The inner views can access the ``ValidationEngine`` using the [Environment](https://developer.apple.com/documentation/swiftui/environment/init(_:)-8slkf)
property wrapper.

### Managing Validation

Parent views can access the validation state of their child views using the ``ValidationState`` property wrapper
and the ``SwiftUI/View/receiveValidation(in:)`` modifier.

The code example below shows
how you can use the validation state of your subview to perform final validation on a button press.

```swift
@ValidationState var validation

var body: some View {
    Form {
        // all subviews that collect data ...

        Button("Submit") {
            guard validation.validateSubviews() else {
                return
            }

            // save data ...
        }
    }
        .receiveValidation(in: $validation)
}
```

## Topics

### Performing Validation

- ``ValidationRule``
- ``SwiftUI/View/validate(input:rules:)-5dac4``
- ``SwiftUI/View/validate(input:rules:)-9vks0``

### Managing Validation

- ``ValidationState``
- ``SwiftUI/View/receiveValidation(in:)``

### Configuration

- ``SwiftUI/EnvironmentValues/validationConfiguration``
- ``SwiftUI/EnvironmentValues/validationDebounce``

### Visualizing Validation

- ``VerifiableTextField``
- ``ValidationResultsView``
- ``FailedValidationResult``
