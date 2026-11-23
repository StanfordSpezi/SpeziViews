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

@Column {
    @Image(source: "Validation", alt: "Three different kinds of text fields showing validation errors in red text.") {
        Perform and visualize input validation with ease using ``SwiftUI/View/validate(input:rules:)-9vks0`` and ``VerifiableTextField``.
    }
}

### Performing Validation

The only thing you have to do, is to set up the ``SwiftUICore/View/validate(input:rules:)-5dac4`` modifier for your
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

### Defining Validation Rules

SpeziValidation provides built-in rules, such as ``ValidationRule/nonEmpty``, ``ValidationRule/minimalEmail``, and ``ValidationRule/minimalPassword``.
You can define your own rules using a closure or a regular expression.
The message is shown to the user if the input doesn't satisfy the rule.

```swift
extension ValidationRule {
    static let zipCode = ValidationRule(
        regex: /[0-9]{5}/,
        message: "Enter a five-digit ZIP code."
    )
}
```

You can pass multiple rules to the ``SwiftUICore/View/validate(input:rules:)-5dac4`` modifier.
By default, all rules are evaluated, and the messages of all failed rules are shown.
Use ``ValidationRule/intercepting`` to skip the remaining rules if a rule fails.

```swift
VerifiableTextField("ZIP Code", text: $zipCode)
    .validate(input: zipCode, rules: ValidationRule.nonEmpty.intercepting, .zipCode)
    .textContentType(.postalCode)
```

> Tip: Set a [text content type](https://developer.apple.com/documentation/swiftui/view/textcontenttype(_:)-ufdv)
    on your text fields so that the system can offer AutoFill suggestions.

> Important: Validation rules only run on the client. Always enforce security-relevant restrictions, such as password requirements, on the server as well.

### Managing Validation

Parent views can access the validation state of their child views using the ``ValidationState`` property wrapper
and the ``SwiftUICore/View/receiveValidation(in:)`` modifier.

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
- ``SwiftUICore/View/validate(input:rules:)-5dac4``
- ``SwiftUICore/View/validate(input:rules:)-9vks0``
- ``SwiftUICore/View/validate(_:message:)``

### Managing Validation

- ``ValidationState``
- ``SwiftUICore/View/receiveValidation(in:)``

### Configuration

- ``SwiftUICore/EnvironmentValues/validationConfiguration``
- ``SwiftUICore/EnvironmentValues/validationDebounce``

### Visualizing Validation

- ``VerifiableTextField``
- ``ValidationResultsView``
- ``FailedValidationResult``
