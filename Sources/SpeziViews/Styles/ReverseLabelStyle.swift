//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A label style that shows the title and icon in reverse layout compared to the standard `titleAndIcon` label style.
public struct ReverseLabelStyle: LabelStyle {
    public func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.title
            configuration.icon
        }
            .accessibilityElement(children: .combine)
    }
}


extension LabelStyle where Self == ReverseLabelStyle {
    /// A label style that shows the title and icon in reverse layout compared to the standard `titleAndIcon` label style.
    public static var reverse: ReverseLabelStyle {
        ReverseLabelStyle()
    }
}


#if DEBUG
#Preview {
    VStack {
        SwiftUI.Label {
            Text(verbatim: "75 %")
        } icon: {
            Image(systemName: "battery.100")
        }
        SwiftUI.Label {
            Text(verbatim: "75 %")
        } icon: {
            Image(systemName: "battery.100")
        }
        .labelStyle(.reverse)
    }
}
#endif
