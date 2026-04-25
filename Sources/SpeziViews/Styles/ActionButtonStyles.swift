//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A button style for primary actions across the Spezi ecosystem.
public struct PrimaryActionButtonStyle: PrimitiveButtonStyle {
    @_documentation(visibility: internal)
    public func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role, action: configuration.trigger) {
            configuration.label
                .bold()
                .frame(maxWidth: .infinity, minHeight: 38)
        }
        .buttonStyleGlassProminent()
    }
}


/// A button style for secondary actions across the Spezi ecosystem.
public struct SecondaryActionButtonStyle: PrimitiveButtonStyle {
    @_documentation(visibility: internal)
    public func makeBody(configuration: Configuration) -> some View {
        Button(role: configuration.role, action: configuration.trigger) {
            configuration.label
        }
        .buttonStyleGlass()
        .padding(.vertical, 10)
    }
}


extension PrimitiveButtonStyle where Self == PrimaryActionButtonStyle {
    /// A button style for primary actions across the Spezi ecosystem.
    public static var primaryAction: PrimaryActionButtonStyle {
        .init()
    }
}


extension PrimitiveButtonStyle where Self == SecondaryActionButtonStyle {
    /// A button style for secondary actions across the Spezi ecosystem.
    public static var secondaryAction: SecondaryActionButtonStyle {
        .init()
    }
}


extension View {
    /// Applies the Spezi primary action button style.
    public func buttonStylePrimaryAction() -> some View {
        self.buttonStyle(.primaryAction)
    }

    /// Applies the Spezi secondary action button style.
    public func buttonStyleSecondaryAction() -> some View {
        self.buttonStyle(.secondaryAction)
    }
}
