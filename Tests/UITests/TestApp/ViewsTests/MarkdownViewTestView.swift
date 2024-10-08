//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct MarkdownViewTestView: View {
    @State var viewState: ViewState = .idle
    
    var body: some View {
        MarkdownView(
            asyncMarkdown: {
                try? await Task.sleep(for: .seconds(2))
                return Data("This is a *markdown* **example** taking 2 seconds to load.".utf8)
            }
        )
        MarkdownView(
            markdown: Data("This is a *markdown* **example**.".utf8)
        )
    }
}


#if DEBUG
struct MarkdownViewTestView_Previews: PreviewProvider {
    static var previews: some View {
        MarkdownViewTestView()
    }
}
#endif
