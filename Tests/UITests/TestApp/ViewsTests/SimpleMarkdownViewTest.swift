//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SpeziViews
import SwiftUI


struct SimpleMarkdownViewTest: View {
    @State private var viewState: ViewState = .idle
    @State private var textAlignment: TextAlignment = .center
    
    var body: some View {
        ScrollView {
            Group {
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
            .multilineTextAlignment(textAlignment)
            .padding(.horizontal)
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                HStack {
                    Text("Text Alignment")
                    Spacer()
                    Picker("", selection: $textAlignment) {
                        ForEach(TextAlignment.allCases, id: \.self) { alignment in
                            Text(alignment.debugName)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}


extension TextAlignment {
    var debugName: String {
        switch self {
        case .leading:
            "leading"
        case .trailing:
            "trailing"
        case .center:
            "center"
        }
    }
}


#if DEBUG
#Preview {
    SimpleMarkdownViewTest()
}
#endif
