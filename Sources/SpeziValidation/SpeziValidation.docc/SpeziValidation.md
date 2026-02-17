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

#### Basic Validation

```swift
@State private var phrase: String = ""

var body: some View {
    Form {
        VerifiableTextField("your favorite phrase", text: $phrase)
            .validate(input: phrase, rules: .nonEmpty)
    }
}
```

#### Multiple Validation Rules

Combine multiple rules for comprehensive validation:

```swift
@State private var email = ""
@State private var password = ""

var body: some View {
    Form {
        VerifiableTextField("Email", text: $email)
            .validate(input: email, rules: .minimalEmail)
            .textInputAutocapitalization(.never)
        
        VerifiableTextField("Password", text: $password, type: .secure)
            .validate(input: password, rules: .minimalPassword)
    }
}
```

#### Custom Validation Rules

Create your own validation logic:

```swift
extension ValidationRule {
    static let strongPassword = ValidationRule(
        rule: { password in
            password.count >= 8 && 
            password.contains { $0.isUppercase } &&
            password.contains { $0.isLowercase } &&
            password.contains { $0.isNumber }
        },
        message: "Password must be at least 8 characters with uppercase, lowercase, and numbers"
    )
}

VerifiableTextField("Strong Password", text: $password, type: .secure)
    .validate(input: password, rules: .strongPassword)
```

> Note: The inner views can access the ``ValidationEngine`` using the [Environment](https://developer.apple.com/documentation/swiftui/environment/init(_:)-8slkf)
property wrapper.

### Managing Validation

Parent views can access the validation state of their child views using the ``ValidationState`` property wrapper
and the ``SwiftUICore/View/receiveValidation(in:)`` modifier.

#### Form-Level Validation

The code example below shows
how you can use the validation state of your subview to perform final validation on a button press.

```swift
@State private var email = ""
@State private var username = ""
@ValidationState private var validation

var body: some View {
    Form {
        Section("Account Details") {
            VerifiableTextField("Email", text: $email)
                .validate(input: email, rules: .minimalEmail)
            
            VerifiableTextField("Username", text: $username)
                .validate(input: username, rules: .nonEmpty)
        }
        
        Section {
            Button("Create Account") {
                guard validation.validateSubviews() else {
                    return // Validation failed
                }
                
                // All validation passed, proceed with account creation
                createAccount()
            }
            .disabled(!validation.allInputValid)
        }
    }
    .receiveValidation(in: $validation)
}
```

#### Real-Time Validation State

Monitor validation state in real-time:

```swift
@ValidationState private var validation

var body: some View {
    VStack {
        // Your form fields here...
        
        if !validation.allInputValid {
            Text("Please fix the errors above")
                .foregroundColor(.red)
        }
        
        Button("Submit") {
            validation.validateSubviews()
        }
        .disabled(!validation.allInputValid)
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
