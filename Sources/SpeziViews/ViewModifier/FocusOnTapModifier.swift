//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct FocusOnTapModifier: ViewModifier {
    @FocusState var isFocused: Bool

    init() {}
    
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused) // tracks focus state
            .onTapGesture {
                isFocused = true
            }
    }
}


extension View {
    /// Move focus to this view when it is tapped.
    ///
    /// The the view is modified such that it receives focus once it is tapped.
    ///
    /// This modifier is useful, e.g., in combination with the ``DescriptionGridRow`` when
    /// used with a `TextField`. This enables the user to focus the text field by tapping the description label.
    ///
    /// - Returns: The modified view.
    public func focusOnTap() -> some View {
        modifier(FocusOnTapModifier())
    }
}
