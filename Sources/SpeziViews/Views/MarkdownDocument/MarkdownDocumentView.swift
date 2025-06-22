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


public struct MarkdownDocumentView<CustomElementView: View>: View {
    public struct DividerRule {
        @inlinable public static var never: Self {
            .init { _, _ in false }
        }
        
        @inlinable public static var always: Self {
            .init { _, _ in true }
        }
        
        @inlinable
        public static func custom( // swiftlint:disable:this type_contents_order
            _ shouldInsertDivider: @escaping @MainActor (_ fstBlockIdx: Int, _ sndBlockIdx: Int) -> Bool
        ) -> Self {
            .init(shouldInsertDivider: shouldInsertDivider)
        }
        
        fileprivate let shouldInsertDivider: @MainActor (_ fstBlockIdx: Int, _ sndBlockIdx: Int) -> Bool
        
        @usableFromInline
        init(shouldInsertDivider: @escaping @MainActor (_ fstBlockIdx: Int, _ sndBlockIdx: Int) -> Bool) {
            self.shouldInsertDivider = shouldInsertDivider
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
                if !isLast && dividerRule.shouldInsertDivider(blockIdx, blockIdx + 1) {
                    Divider()
                }
            }
        }
    }
    
    
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
