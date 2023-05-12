//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A lazy loading text view that is especially useful for larger text files that should not be displayed all at once.
///
/// Uses a `LazyVStack` under the hood to load and display the text line-by-line.
public struct LazyText: View {
    private let text: String
    
    
    private var lines: [(id: UUID, text: String)] {
        var lines: [(id: UUID, text: String)] = []
        text.enumerateLines { line, _ in
            lines.append((UUID(), line))
        }
        return lines
    }
    
    public var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(lines, id: \.id) { line in
                Text(line.text)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    
    /// A lazy loading text view that is especially useful for larger text files that should not be displayed all at once.
    /// - Parameter text: The text that should be displayed in the ``LazyText`` view.
    public init(text: String) {
        self.text = text
    }
}


#if DEBUG
struct LazyText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyText(
                text: """
                This is a long text ...
                
                And some more lines ...
                
                And a third line ...
                """
            )
        }
    }
}
#endif
