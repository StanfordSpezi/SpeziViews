//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SkeletonLoadingExample: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 10)
            #if canImport(UIKit)
                .fill(Color(UIColor.systemGray4))
            #elseif canImport(AppKit)
                .fill(Color(NSColor.systemGray))
            #endif
                .frame(height: 100)
                .skeletonLoading(replicationCount: 5, repeatInterval: 1.5, spacing: 16)
            Spacer()
        }
            .padding()
    }
}


#if DEBUG
#Preview {
    SkeletonLoadingExample()
}
#endif
