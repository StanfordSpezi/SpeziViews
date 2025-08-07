<!--

This source file is part of the Stanford Spezi open-source project.

SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)

SPDX-License-Identifier: MIT
  
-->

# Spezi Views

[![Build and Test](https://github.com/StanfordSpezi/SpeziViews/actions/workflows/build-and-test.yml/badge.svg)](https://github.com/StanfordSpezi/SpeziViews/actions/workflows/build-and-test.yml)
[![codecov](https://codecov.io/gh/StanfordSpezi/SpeziViews/branch/main/graph/badge.svg?token=tLnPSYE6W9)](https://codecov.io/gh/StanfordSpezi/SpeziViews)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.7806475.svg)](https://doi.org/10.5281/zenodo.7806475)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziViews%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/StanfordSpezi/SpeziViews)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2FStanfordSpezi%2FSpeziViews%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/StanfordSpezi/SpeziViews)

A Spezi framework that provides a common set of SwiftUI views and related functionality used across the Spezi ecosystem.

## Overview

SpeziViews provides easy-to-use and easily-reusable UI components that makes the everyday life of developing Spezi applications easier.

The framework consists of three main modules:

- **SpeziViews**: Core UI components, view state management, buttons, layouts, and navigation
- **SpeziPersonalInfo**: Components for handling personal information like name fields
- **SpeziValidation**: Input validation with visual feedback

|![A SwiftUI alert displayed using the SpeziViews ViewState.](Sources/SpeziViews/SpeziViews.docc/Resources/ViewState.png#gh-light-mode-only) ![A SwiftUI alert displayed using the SpeziViews ViewState.](Sources/SpeziViews/SpeziViews.docc/Resources/ViewState~dark.png#gh-dark-mode-only)|![Three text fields to input your first, middle and last name.](Sources/SpeziPersonalInfo/SpeziPersonalInfo.docc/Resources/NameFields.png#gh-light-mode-only) ![Three text fields to input your first, middle and last name.](Sources/SpeziPersonalInfo/SpeziPersonalInfo.docc/Resources/NameFields~dark.png#gh-dark-mode-only)| ![Three different kinds of text fields showing validation errors in red text.](Sources/SpeziValidation/SpeziValidation.docc/Resources/Validation.png#gh-light-mode-only) ![Three different kinds of text fields showing validation errors in red text.](Sources/SpeziValidation/SpeziValidation.docc/Resources/Validation~dark.png#gh-dark-mode-only) |
|:--:|:--:|:--:|
|Easily manage view state and display erroneous state using [`ViewState`](https://swiftpackageindex.com/stanfordspezi/speziviews/documentation/speziviews/viewstate). |The [SpeziPersonalInfo](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezipersonalinfo) provides easy to use abstractions for dealing with personal information. |Perform and visualize input validation with ease using [SpeziValidation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation/spezivalidation).|

## Setup

You need to add the SpeziViews Swift package to
[your app in Xcode](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app#) or
[Swift package](https://developer.apple.com/documentation/xcode/creating-a-standalone-swift-package-with-xcode#Add-a-dependency-on-another-Swift-package).

> [!IMPORTANT]  
> If your application is not yet configured to use Spezi, follow the [Spezi setup article](https://swiftpackageindex.com/stanfordspezi/spezi/documentation/spezi/initial-setup) to set up the core Spezi infrastructure.

## Usage Examples

### SpeziViews - Core Components

#### View State Management

Manage async operations and display loading states or errors using `ViewState`:

```swift
import SpeziViews
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        Form {
            TextField("Email", text: $email)
            SecureField("Password", text: $password)
            
            AsyncButton("Sign In", state: $viewState) {
                try await performLogin()
            }
        }
        .viewStateAlert(state: $viewState)
    }
    
    private func performLogin() async throws {
        // Your async login logic here
    }
}
```

#### Async Button

Handle async operations with built-in loading states:

```swift
import SpeziViews
import SwiftUI

struct DataView: View {
    @State private var viewState: ViewState = .idle
    
    var body: some View {
        VStack {
            AsyncButton("Download Data", state: $viewState) {
                try await downloadData()
            }
            .asyncButtonProcessingStyle(.listRow)
        }
        .viewStateAlert(state: $viewState)
    }
    
    private func downloadData() async throws {
        try await Task.sleep(for: .seconds(2))
        // Download logic
    }
}
```

#### Tiles and Layout

Create card-like layouts with `SimpleTile`:

```swift
import SpeziViews
import SwiftUI

struct BookView: View {
    var body: some View {
        SimpleTile(alignment: .leading) {
            TileHeader(alignment: .leading) {
                Image(systemName: "book.pages.fill")
                    .foregroundStyle(.teal)
                    .font(.largeTitle)
            } title: {
                Text("Clean Code")
            } subheadline: {
                Text("by Robert C. Martin")
            }
        } body: {
            Text("A handbook of agile software craftsmanship")
        } footer: {
            Button("Read More") {
                // Action
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

#### Managed Navigation

Create step-by-step navigation flows:

```swift
import SpeziViews
import SwiftUI

struct OnboardingView: View {
    @State private var path = ManagedNavigationStack.Path()
    
    var body: some View {
        ManagedNavigationStack(path: path) {
            WelcomeStep()
            ProfileStep()
            NotificationStep()
            CompletionStep()
        }
    }
}

private struct WelcomeStep: View {
    @Environment(ManagedNavigationStack.Path.self) private var path
    
    var body: some View {
        VStack {
            Text("Welcome to the App!")
            Button("Continue") {
                path.nextStep()
            }
        }
    }
}
```

#### Share Sheet

Easily share content with the system share sheet:

```swift
import SpeziViews
import SwiftUI

struct ShareView: View {
    @State private var itemToShare: ShareSheetInput?
    
    var body: some View {
        VStack {
            Button("Share Text") {
                itemToShare = ShareSheetInput("Hello World!")
            }
            
            Button("Share Image") {
                if let image = UIImage(systemName: "star") {
                    itemToShare = ShareSheetInput(image)
                }
            }
        }
        .shareSheet(item: $itemToShare)
    }
}
```

#### Skeleton Loading

Add skeleton loading animations:

```swift
import SpeziViews
import SwiftUI

struct LoadingView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.systemGray4))
                .frame(height: 100)
                .skeletonLoading(replicationCount: 5, repeatInterval: 1.5, spacing: 16)
        }
        .padding()
    }
}
```

### SpeziPersonalInfo - Personal Information

Handle name input with proper formatting:

```swift
import SpeziPersonalInfo
import SwiftUI

struct ProfileSetupView: View {
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
                    
                    NameFieldRow("Middle", name: $name, for: \.middleName) {
                        Text("Enter your middle name (optional)")
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

### SpeziValidation - Input Validation

Add real-time validation to forms:

```swift
import SpeziValidation
import SwiftUI

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    
    @ValidationState private var validation
    
    var body: some View {
        Form {
            Section("Account Details") {
                VerifiableTextField("Email", text: $email)
                    .validate(input: email, rules: .minimalEmail)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                VerifiableTextField("Password", text: $password, type: .secure)
                    .validate(input: password, rules: .minimalPassword)
                
                VerifiableTextField("Username", text: $username)
                    .validate(input: username, rules: .nonEmpty)
            } footer: {
                Text("Choose a unique username")
            }
        }
        .receiveValidation(in: $validation)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Create Account") {
                    guard validation.validateSubviews() else {
                        return
                    }
                    // Create account
                }
                .disabled(!validation.allInputValid)
            }
        }
    }
}
```

#### Custom Validation Rules

Create custom validation logic:

```swift
import SpeziValidation
import SwiftUI

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

struct SecureSignupView: View {
    @State private var password = ""
    
    var body: some View {
        Form {
            VerifiableTextField("Password", text: $password, type: .secure)
                .validate(input: password, rules: .strongPassword)
        }
    }
}
```

#### Validation with Multiple Rules

Combine multiple validation rules:

```swift
import SpeziValidation
import SwiftUI

struct ContactForm: View {
    @State private var fullName = ""
    @State private var email = ""
    
    var body: some View {
        Form {
            VerifiableTextField("Full Name", text: $fullName)
                .validate(input: fullName, rules: [.nonEmpty, .unicodeLettersOnly])
            
            VerifiableTextField("Email", text: $email)
                .validate(input: email, rules: .minimalEmail)
        }
    }
}
```

## Additional Components and Utilities

### Canvas View

Create drawable canvases for signatures or sketches:

```swift
import SpeziViews
import SwiftUI
import PencilKit

struct SignatureView: View {
    @State private var drawing = PKDrawing()
    
    var body: some View {
        VStack {
            CanvasView(drawing: $drawing)
                .frame(height: 200)
                .border(Color.gray)
            
            HStack {
                Button("Clear") {
                    drawing = PKDrawing()
                }
                Button("Save") {
                    let image = drawing.image(from: CGRect(x: 0, y: 0, width: 400, height: 200), scale: 1.0)
                    // Save image
                }
            }
        }
    }
}
```

### Pickers

Use specialized pickers for enums and option sets:

```swift
import SpeziViews
import SwiftUI

enum Priority: String, CaseIterable {
    case low = "Low"
    case medium = "Medium" 
    case high = "High"
}

struct OptionFlags: OptionSet {
    let rawValue: Int
    static let notifications = OptionFlags(rawValue: 1 << 0)
    static let location = OptionFlags(rawValue: 1 << 1)
    static let camera = OptionFlags(rawValue: 1 << 2)
}

struct SettingsView: View {
    @State private var priority: Priority = .medium
    @State private var permissions: OptionFlags = []
    
    var body: some View {
        Form {
            Section("Priority") {
                CaseIterablePicker("Task Priority", selection: $priority)
            }
            
            Section("Permissions") {
                OptionSetPicker(selection: $permissions) {
                    Text("Notifications").tag(OptionFlags.notifications)
                    Text("Location").tag(OptionFlags.location)
                    Text("Camera").tag(OptionFlags.camera)
                }
            }
        }
    }
}
```

### List Components

Enhanced list components with better styling:

```swift
import SpeziViews
import SwiftUI

struct EnhancedListView: View {
    var body: some View {
        List {
            ListHeader("Settings") {
                Text("Customize your app experience")
            }
            
            ListRow("Notifications") {
                Image(systemName: "bell")
            } action: {
                // Handle tap
            }
            
            ListRow("Privacy") {
                Image(systemName: "lock.shield")
            } action: {
                // Handle tap  
            }
        }
    }
}
```

### Text and Labels

Rich text rendering with Markdown support:

```swift
import SpeziViews
import SwiftUI

struct DocumentView: View {
    let markdownContent = """
    # Welcome to SpeziViews
    
    This is **bold** text and this is *italic* text.
    
    - Feature 1
    - Feature 2
    - Feature 3
    
    [Learn more](https://example.com)
    """
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                MarkdownView(markdown: markdownContent)
                
                Label("Custom Label", systemImage: "star.fill")
                    .labelStyle(.reverse)
                
                LazyText("This text loads efficiently")
            }
            .padding()
        }
    }
}
```

### View Modifiers

Useful view modifiers for common patterns:

```swift
import SpeziViews
import SwiftUI

struct ConditionalView: View {
    @State private var showDetails = false
    @State private var isLoading = true
    @State private var orientation = UIDevice.current.orientation
    
    var body: some View {
        VStack {
            Text("Main Content")
                .if(showDetails) { view in
                    view.font(.title)
                }
                .focusOnTap()
            
            Button("Toggle Details") {
                showDetails.toggle()
            }
        }
        .shimmer(repeatInterval: 2.0)
        .processingOverlay(isProcessing: $isLoading)
        .observeOrientationChanges($orientation)
        .onChange(of: orientation) { newOrientation in
            print("Device orientation: \(newOrientation)")
        }
    }
}
```

For more information, please refer to the [API documentation](https://swiftpackageindex.com/StanfordSpezi/SpeziViews/documentation).

## Contributing

Contributions to this project are welcome. Please make sure to read the [contribution guidelines](https://github.com/StanfordSpezi/.github/blob/main/CONTRIBUTING.md) and the [contributor covenant code of conduct](https://github.com/StanfordSpezi/.github/blob/main/CODE_OF_CONDUCT.md) first.

## License

This project is licensed under the MIT License. See [Licenses](https://github.com/StanfordSpezi/SpeziViews/tree/main/LICENSES) for more information.

![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer.png#gh-light-mode-only)
![Spezi Footer](https://raw.githubusercontent.com/StanfordSpezi/.github/main/assets/Footer~dark.png#gh-dark-mode-only)
