//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


private struct TextLine: Identifiable {
    var id: UUID
    var line: String
}


/// A lazy loading text view that is especially useful for larger text files that should not be displayed all at once.
///
/// Uses a `LazyVStack` under the hood to load and display the text line-by-line.
public struct LazyText: View {
    private let content: TextContent

    @Environment(\.locale) private var locale
    
    
    private var lines: [TextLine] {
        var lines: [TextLine] = []
        content.localizedString(for: locale).enumerateLines { line, _ in
            lines.append(TextLine(id: UUID(), line: line))
        }
        return lines
    }
    
    public var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(lines) { line in
                Text(verbatim: line.line)
                    .multilineTextAlignment(.leading)
            }
        }
    }
    
    
    /// A lazy loading text view that is especially useful for larger text files that should not be displayed all at once.
    /// - Parameter text: The text without localization that should be displayed in the ``LazyText`` view.
    @_disfavoredOverload
    public init<Text: StringProtocol>(verbatim text: Text) {
        self.content = .string(String(text))
    }
    
    /// A lazy loading text view that is especially useful for larger text files that should not be displayed all at once.
    /// - Parameter text: The text that should be displayed in the ``LazyText`` view.
    public init(_ text: LocalizedStringResource) {
        self.content = .localized(text)
    }
}


#if DEBUG
struct LazyText_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyText(
                verbatim: """
                This is a long text ...
                
                And some more lines ...
                
                And a third line ...
                """
            )
        }
    }
}
#endif
