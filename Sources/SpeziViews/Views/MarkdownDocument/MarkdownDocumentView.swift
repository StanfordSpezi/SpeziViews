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
/// - Note: The `MarkdownDocumentView` intentionally does not wrap its contents in a `ScrollView`.
///     Instead, the parent view should ensure that a `MarkdownDocumentView` is always placed within a `ScrollView`.
///
/// ## Topics
///
/// ### Initializers
/// - ``init(markdownDocument:dividerRule:)``
/// - ``init(markdownDocument:dividerRule:customElementViewProvider:)``
/// - ``DividerRule``
public struct MarkdownDocumentView<CustomElementView: View>: View {
    /// Defines when the ``MarkdownDocumentView`` places `Divider`s between its sections.
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
    
    
    private let markdownDocument: MarkdownDocument
    private let dividerRule: DividerRule
    private let customElementViewProvider: @MainActor (_ blockIdx: Int, _ element: MarkdownDocument.CustomElement) -> CustomElementView
    
    public var body: some View {
        let blocks = markdownDocument.blocks
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
    
    /// Creates a new MarkdownDocumentView
    ///
    /// - parameter markdownDocument: The [`MarkdownDocument`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/markdowndocument) the view should display
    /// - parameter dividerRule: Defines when the view should place a `Divider` between two sections
    public init(
        markdownDocument: MarkdownDocument,
        dividerRule: DividerRule
    ) where CustomElementView == EmptyView {
        self.init(markdownDocument: markdownDocument, dividerRule: dividerRule) { _, _ in
            EmptyView()
        }
    }
    
    /// Creates a new MarkdownDocumentView
    ///
    /// - parameter markdownDocument: The [`MarkdownDocument`](https://swiftpackageindex.com/stanfordspezi/spezifoundation/documentation/spezifoundation/markdowndocument) the view should display
    /// - parameter dividerRule: Defines when the view should place a `Divider` between two sections
    /// - parameter customElementViewProvider: A `ViewBuilder` closure that provides backing views for custom elements in the Markdown which cannot be handled by the ``MarkdownDocumentView`` itself.
    public init(
        markdownDocument: MarkdownDocument,
        dividerRule: DividerRule,
        @ViewBuilder customElementViewProvider: @escaping @MainActor (_ blockIdx: Int, _ element: MarkdownDocument.CustomElement) -> CustomElementView
    ) {
        self.markdownDocument = markdownDocument
        self.dividerRule = dividerRule
        self.customElementViewProvider = customElementViewProvider
    }
    
    
    @ViewBuilder
    private func view(for block: MarkdownDocument.Block, at idx: Int) -> some View {
        switch block {
        case .markdown(id: _, let content):
            HStack {
                Markdown(content)
                Spacer()
                // we can't seem to get the `Markdown` view to make itself as wide as possible, so this is the next best option :/
            }
        case .customElement(let element):
            customElementViewProvider(idx, element)
        }
    }
}
