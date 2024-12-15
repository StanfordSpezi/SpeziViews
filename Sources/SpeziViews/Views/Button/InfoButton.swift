//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Icon-only info button.
///
/// You can use this button, e.g., on the trailing side of a list row to provide additional information about an entity.
public struct InfoButton: View {
    private let label: Text
    private let action: () -> Void

    public var body: some View {
        Button(action: action) {
            SwiftUI.Label {
                label
            } icon: {
                Image(systemName: "info.circle") // swiftlint:disable:this accessibility_label_for_image
            }
        }
            .labelStyle(.iconOnly)
            .font(.title3)
            .foregroundColor(.accentColor)
            .buttonStyle(.borderless) // ensure button is clickable next to the other button
            .accessibilityIdentifier("info-button")
    #if !(TEST || targetEnvironment(simulator)) // accessibility actions cannot be unit tested
            .accessibilityAction(named: label, action)
            .accessibilityHidden(true)
    #endif
    }
    
    /// Create a new info button.
    /// - Parameters:
    ///   - label: The text label. This is not shown but useful for accessibility.
    ///   - action: The button action.
    public init(_ label: Text, action: @escaping () -> Void) {
        self.label = label
        self.action = action
    }
    
    /// Create a new info button.
    /// - Parameters:
    ///   - resource: The localized button label. This is not shown but useful for accessibility.
    ///   - action: The button action.
    public init(_ resource: LocalizedStringResource, action: @escaping () -> Void) {
        self.label = Text(resource)
        self.action = action
    }
}


#if DEBUG
#Preview {
    List {
        Button {
            print("Primary")
        } label: {
            ListRow("Entry") {
                InfoButton("Entry Info") {
                    print("Info")
                }
            }
        }
    }
}
#endif
