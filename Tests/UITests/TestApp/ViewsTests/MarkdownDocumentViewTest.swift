//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import SpeziFoundation
import SpeziViews
import SwiftUI


struct MarkdownDocumentViewTest: View {
    private let document = try! MarkdownDocument( // swiftlint:disable:this force_try
        processing: """
            ---
            title: Welcome to the Spezi Ecosystem
            date: 2025-06-22T14:41:16+02:00
            ---
            
            # Welcome to the Spezi Ecosystem
            This article aims to provide you with a broad overview of Spezi.
            
            <marquee />
            
            ## Our Modules
            Spezi is architected to be a highly modular system, allowing your application to ...
            """,
        customElementNames: ["marquee"]
    )
    
    var body: some View {
        ScrollView {
            MarkdownDocumentView(markdownDocument: document, dividerRule: .always) { _, element in
                switch element.name {
                case "marquee":
                    Marquee {
                        let image = UIImage(named: "lukas_smol.png")! // swiftlint:disable:this force_unwrapping object_literal
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: image.size.width * (52 / image.size.height), height: 52)
                    }
                    .accessibilityElement()
                    .accessibilityIdentifier("ayooooooo")
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
    }
}


private struct Marquee<Content: View>: View {
    /// how many seconds a full left-right movement corresponds to
    private static var period: TimeInterval { 5 }
    
    @ViewBuilder let content: @MainActor () -> Content
    @State private var overallWidth: CGFloat = 440
    @State private var contentSize: CGSize = .zero
    @State private var contentSizeChanges = AsyncStream.makeStream(of: CGSize.self)
    
    var body: some View {
        let start = Date.now
        GeometryReader { geometry in
            TimelineView(.animation) { context in
                let progress = context.date.timeIntervalSince(start)
                content()
                    .offset(x: xOffset(for: progress))
                    .background(
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: ContentSizePreferenceKey.self,
                                value: geometry.size
                            )
                        }
                    )
                    .onPreferenceChange(ContentSizePreferenceKey.self) { size in
                        contentSizeChanges.continuation.yield(size)
                    }
            }
            .onChange(of: geometry.size.width, initial: true) { _, overallWidth in
                self.overallWidth = overallWidth
            }
        }
        .frame(height: contentSize.height) // need to set this explicitly, for some wretched reason...
        .task {
            for await size in contentSizeChanges.stream {
                contentSize = size
            }
            contentSizeChanges = AsyncStream.makeStream()
        }
    }
    
    private func xOffset(for progress: CGFloat) -> CGFloat {
        let distance = sin((progress / Self.period) * .pi)
        let validRange = overallWidth - contentSize.width
        let offset = (validRange / 2) + ((validRange / 2) * distance)
        return offset
    }
}

extension Marquee {
    private struct ContentSizePreferenceKey: PreferenceKey {
        static var defaultValue: CGSize { .zero }
        
        static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
            value = nextValue()
        }
    }
}
