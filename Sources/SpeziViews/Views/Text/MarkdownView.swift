//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// A ``MarkdownView`` allows the display of a markdown file including the addition of a header and footer view.
///
/// ```swift
/// @State var viewState: ViewState = .idle
///
/// MarkdownView(
///     asyncMarkdown: {
///         // Load your markdown file from a remote source or disk storage ...
///         try? await Task.sleep(for: .seconds(5))
///         return Data("This is a *markdown* **example** taking 5 seconds to load.".utf8)
///     },
///     state: $viewState
/// )
/// ```
public struct MarkdownView: View {
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
    
    
    private let buildMarkdown: () async throws -> AttributedString
    
    @State private var markdownContent: AttributedString?
    @Binding private var state: ViewState
    
    
    public var body: some View {
        VStack {
            if let markdownContent {
                Text(markdownContent)
            } else {
                ProgressView()
                    .padding()
            }
        }
            .task {
                markdownContent = await updateMarkdown()
            }
    }
    
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown file as an utf8 representation that is loaded asynchronously.
    /// - Parameters:
    ///   - asyncMarkdown: An async throwing closure to load the markdown in an utf8 representation.
    ///   - options: Options on how to parse the markdown into an attributed string.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    public init(
        asyncMarkdown: @escaping () async throws -> Data,
        options: AttributedString.MarkdownParsingOptions = .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            attributedString: {
                try AttributedString(
                    markdown: try await asyncMarkdown(),
                    options: options
                )
            },
            state: state
        )
    }
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown file
    /// - Parameters:
    ///   - asyncMarkdown: A `Data` instance containing the markdown file in an utf8 representation.
    ///   - options: Options on how to parse the markdown into an attributed string.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    public init(
        markdown: Data,
        options: AttributedString.MarkdownParsingOptions = .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            asyncMarkdown: { markdown },
            state: state
        )
    }
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown string that is loaded asynchronously.
    /// - Parameters:
    ///   - asyncMarkdown: An async throwing closure to load the markdown as a string.
    ///   - options: Options on how to parse the markdown into an attributed string.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    public init(
        asyncMarkdown: @escaping () async throws -> String,
        options: AttributedString.MarkdownParsingOptions = .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            attributedString: {
                try AttributedString(
                    markdown: try await asyncMarkdown(),
                    options: options
                )
            },
            state: state
        )
    }
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown file
    /// - Parameters:
    ///   - asyncMarkdown: A `String` instance containing the markdown file.
    ///   - options: Options on how to parse the markdown into an attributed string.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    public init(
        markdown: String,
        options: AttributedString.MarkdownParsingOptions = .init(interpretedSyntax: .inlineOnlyPreservingWhitespace),
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            asyncMarkdown: { markdown },
            state: state
        )
    }
    
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown file
    /// - Parameters:
    ///   - asyncMarkdown: An `AttributedString` built from markdown data or a string.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    public init(
        attributedString: @escaping () async throws -> AttributedString,
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.buildMarkdown = attributedString
        self._state = state
    }
    
    
    /// Parses the incoming markdown and handles the view's error state management.
    /// - Parameters:
    ///   - markdown: A `Data` instance containing the markdown file in an utf8 representation.
    ///
    /// - Returns: Parsed Markdown as an `AttributedString`
    @MainActor private func updateMarkdown() async -> AttributedString {
        state = .processing
        
        guard let markdownString = try? await buildMarkdown() else {
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
        MarkdownView(markdown: Data("This is a *markdown* **example**!".utf8))
    }
}
#endif
