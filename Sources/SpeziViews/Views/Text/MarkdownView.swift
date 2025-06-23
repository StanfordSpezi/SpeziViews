//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import MarkdownUI
import SpeziFoundation
import SwiftUI


/// Displays a Markdown document, with optional support for dynamic and interactive content.
///
/// You use this view to display [`MarkdownDocument`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/markdowndocument).
///
/// - Note: The `MarkdownView` intentionally does not wrap its contents in a `ScrollView`.
///     Instead, the parent view should ensure that a `MarkdownView` is always placed within a `ScrollView`.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(markdownDocument:dividerRule:)``
/// - ``init(markdownDocument:dividerRule:customElementViewProvider:)``
/// - ``DividerRule``
public struct MarkdownView<CustomElementView: View>: View {
    /// Allows injecting views representing custom elements into the ``MarkdownView``
    public typealias CustomElementViewProvider = @MainActor (
        _ blockIdx: Int,
        _ element: MarkdownDocument.CustomElement
    ) -> CustomElementView
    
    /// Defines when the ``MarkdownView`` places `Divider`s between its sections.
    public struct DividerRule {
        public typealias Predicate = @MainActor (_ blockIdx: Int, _ block: borrowing MarkdownDocument.Block) -> Bool
        
        /// The `MarkdownView` should never place any dividers
        @inlinable public static var never: Self {
            .init { _, _ in false }
        }
        
        /// The `MarkdownView` should always place dividers
        @inlinable public static var always: Self {
            .init { _, _ in true }
        }
        
        /// Creates a `DividerRule` that uses a custom, dynamic condition.
        ///
        /// - parameter shouldInsertDividerAfter: A predicate that returns `true` if a divider should be placed after the block at `blockIdx`.
        @inlinable
        public static func custom(_ shouldInsertDividerAfter: @escaping Predicate) -> Self { // swiftlint:disable:this type_contents_order
            .init(shouldInsertDividerAfter: shouldInsertDividerAfter)
        }
        
        fileprivate let shouldInsertDividerAfter: Predicate
        
        @usableFromInline
        init(shouldInsertDividerAfter: @escaping Predicate) {
            self.shouldInsertDividerAfter = shouldInsertDividerAfter
        }
    }
    
    private enum LoadingState {
        case pending(() async -> Data, viewStateBinding: Binding<ViewState>)
        case loaded(MarkdownDocument)
    }
    
    
    @Environment(\.multilineTextAlignment) private var textAlignment
    
    private let dividerRule: DividerRule
    private let customElementViewProvider: @MainActor (_ blockIdx: Int, _ element: MarkdownDocument.CustomElement) -> CustomElementView
    @State private var loadingState: LoadingState
    
    public var body: some View {
        Group {
            switch loadingState {
            case .pending:
                ProgressView()
                    .padding()
            case .loaded(let document):
                let blocks = document.blocks
                VStack(spacing: 12) {
                    ForEach(Array(blocks.indices), id: \.self) { blockIdx in
                        let block = blocks[blockIdx]
                        view(for: block, at: blockIdx)
                            .id(block.id)
                        let isLast = blockIdx >= blocks.endIndex - 1
                        if !isLast && dividerRule.shouldInsertDividerAfter(blockIdx, block) {
                            Divider()
                        }
                    }
                }
            }
        }
        .task {
            switch loadingState {
            case .loaded:
                break
            case let .pending(markdownData, viewStateBinding):
                viewStateBinding.wrappedValue = .processing
                do {
                    let document = try MarkdownDocument(processing: await markdownData())
                    loadingState = .loaded(document)
                    viewStateBinding.wrappedValue = .idle
                } catch {
                    viewStateBinding.wrappedValue = .error(AnyLocalizedError(error: error))
                    // SAFETY: we statically know this text, and we know that it will parse successfully.
                    loadingState = .loaded(try! MarkdownDocument( // swiftlint:disable:this force_try
                        processing: String(localized: "MARKDOWN_LOADING_ERROR", bundle: .module)
                    ))
                }
            }
        }
    }
    
    private init(loadingState: LoadingState, dividerRule: DividerRule, customElementViewProvider: @escaping CustomElementViewProvider) {
        self._loadingState = .init(initialValue: loadingState)
        self.dividerRule = dividerRule
        self.customElementViewProvider = customElementViewProvider
    }
    
    /// Creates a new MarkdownView
    ///
    /// - parameter markdownDocument: The [`MarkdownDocument`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/markdowndocument) the view should display
    /// - parameter dividerRule: Defines when the view should place a `Divider` between two sections. Defaults to ``DividerRule/never``.
    /// - parameter customElementViewProvider: A `ViewBuilder` closure that provides backing views for custom elements in the Markdown which cannot be handled by the ``MarkdownView`` itself.
    public init(
        markdownDocument: MarkdownDocument,
        dividerRule: DividerRule = .never,
        @ViewBuilder customElementViewProvider: @escaping CustomElementViewProvider = { _, _ in EmptyView() }
    ) {
        self.init(
            loadingState: .loaded(markdownDocument),
            dividerRule: dividerRule,
            customElementViewProvider: customElementViewProvider
        )
    }
    
    
    @ViewBuilder
    private func view(for block: MarkdownDocument.Block, at idx: Int) -> some View {
        switch block {
        case .markdown(id: _, let content):
            // ISSUE: we can't seem to get the `Markdown` view to make itself as wide as possible.
            // SOLUTION: depending on the text alignment, we place the `Markdown` view inside a HStack, alongside a Spacer to push it to the edge.
            switch textAlignment {
            case .center:
                Markdown(content)
            case .trailing:
                HStack(spacing: 0) {
                    Spacer()
                    Markdown(content)
                }
            case .leading:
                HStack(spacing: 0) {
                    Markdown(content)
                    Spacer()
                }
            }
        case .customElement(let element):
            customElementViewProvider(idx, element)
        }
    }
}


// MARK: Backwards Compatibility

extension MarkdownView where CustomElementView == EmptyView {
    /// Creates a ``MarkdownView`` that displays the content of a markdown file as an UTF-8 representation that is loaded asynchronously.
    /// - Parameters:
    ///   - asyncMarkdown: An async closure to load the markdown in an UTF-8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    @available(
        *,
         deprecated,
         renamed: "init(markdownDocument:dividerRule:)",
         message: "Support for asynchronous loading of the markdown `Data` will be removed in a future release and should be moved into clients if they wish to retain this behaviour."
         // swiftlint:disable:previous line_length
    )
    public init(
        asyncMarkdown: @escaping () async -> Data,
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            loadingState: .pending(asyncMarkdown, viewStateBinding: state),
            dividerRule: .never,
            customElementViewProvider: { _, _ in EmptyView() }
        )
    }
    
    /// Creates a ``MarkdownView`` that displays the content of a markdown file
    /// - Parameters:
    ///   - markdown: A `Data` instance containing the markdown file in an UTF-8 representation.
    ///   - state: A `Binding` to observe the ``ViewState`` of the ``MarkdownView``.
    @available(
        *,
         deprecated,
         renamed: "init(markdownDocument:dividerRule:)",
         message: "Support for asynchronous loading of the markdown `Data` will be removed in a future release and should be moved into clients if they wish to retain this behaviour."
         // swiftlint:disable:previous line_length
    )
    public init(
        markdown: Data,
        state: Binding<ViewState> = .constant(.idle)
    ) {
        self.init(
            asyncMarkdown: { markdown },
            state: state
        )
    }
}
