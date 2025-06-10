//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


public enum AsyncButtonProcessingStyle: Hashable, Sendable {
    case overlay
    case listRow
}

extension EnvironmentValues {
    @Entry var asyncButtonProcessingStyle: AsyncButtonProcessingStyle = .overlay
}


extension View {
    public func asyncButtonProcessingStyle(_ style: AsyncButtonProcessingStyle) -> some View {
        environment(\.asyncButtonProcessingStyle, style)
    }
}
