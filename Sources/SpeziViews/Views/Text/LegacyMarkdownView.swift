//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A ``LegacyMarkdownView`` allows the display of a markdown file including the addition of a header and footer view.
///
/// ```swift
/// @State var viewState: ViewState = .idle
///
/// LegacyMarkdownView(
///     asyncMarkdown: {
///         // Load your markdown file from a remote source or disk storage ...
///         try? await Task.sleep(for: .seconds(5))
///         return Data("This is a *markdown* **example** taking 5 seconds to load.".utf8)
///     },
///     state: $viewState
/// )
/// ```
@available(*, deprecated, renamed: "MarkdownView")
public struct LegacyMarkdownView: View {
    public enum Error: LocalizedError {
        case markdownLoadingError
        
        
        public var errorDescription: String? {
            LocalizedStringResource("MARKDOWN_LOADING_ERROR", bundle: .atURL(from: .module)).localizedString()
        }
        
        public var recoverySuggestion: String? {
            LocalizedStringResource("MARKDOWN_LOADING_ERROR_RECOVERY_SUGGESTION", bundle: .atURL(from: .module)).localizedString()
        }

        public var failureReason: String? {
            LocalizedStringResource("MARKDOWN_LOADING_ERROR_FAILURE_REASON", bundle: .atURL(from: .module)).localizedString()
        }
    }
    
    
    private let asyncMarkdown: () async -> Data
    
    @State private var markdownString: AttributedString?
    @Binding private var state: ViewState
    
    
    public var body: some View {
        VStack {
            if let markdownString {
                Text(markdownString)
            } else {
                ProgressView()
                    .padding()
            }
        }
            .task {
                markdownString = parse(
                    markdown: await asyncMarkdown()
                )
            }
    }
    
    
    /// Creates a ``LegacyMarkdownView`` that displays the content of a markdown file as an utf8 representation that is loaded asynchronously.
    /// - Parameters:
    ///   - asyncMarkdown: An async closure to load the markdown in an utf8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``LegacyMarkdownView``.
    public init(
        asyncMarkdown: @escaping () async -> Data,
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.asyncMarkdown = asyncMarkdown
        self._state = state
    }
    
    /// Creates a ``LegacyMarkdownView`` that displays the content of a markdown file
    /// - Parameters:
    ///   - markdown: A `Data` instance containing the markdown file in an utf8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``LegacyMarkdownView``.
    public init(
        markdown: Data,
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            asyncMarkdown: { markdown },
            state: state
        )
    }
    
    
    /// Parses the incoming markdown and handles the view's error state management.
    /// - Parameters:
    ///   - markdown: A `Data` instance containing the markdown file in an utf8 representation.
    ///
    /// - Returns: Parsed Markdown as an `AttributedString`
    @MainActor private func parse(markdown: Data) -> AttributedString {
        state = .processing
        
        guard let markdownString = try? AttributedString(
                markdown: markdown,
                options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace)
              ) else {
            state = .error(Error.markdownLoadingError)
            return AttributedString(
                String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module)
            )
        }
        
        state = .idle
        return markdownString
    }
}


#if DEBUG
struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        LegacyMarkdownView(markdown: Data("This is a *markdown* **example**!".utf8))
    }
}
#endif
