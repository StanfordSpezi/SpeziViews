//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct LegacyMarkdownViewTestView: View {
    @State var viewState: ViewState = .idle
    
    var body: some View {
        LegacyMarkdownView(
            asyncMarkdown: {
                try? await Task.sleep(for: .seconds(2))
                return Data("This is a *markdown* **example** taking 2 seconds to load.".utf8)
            }
        )
        LegacyMarkdownView(
            markdown: Data("This is a *markdown* **example**.".utf8)
        )
    }
}


#if DEBUG
#Preview {
    LegacyMarkdownViewTestView()
}
#endif
