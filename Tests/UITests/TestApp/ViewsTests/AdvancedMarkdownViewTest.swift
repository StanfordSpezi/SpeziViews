//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
import SpeziFoundation
import SpeziViews
import SwiftUI
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif


struct AdvancedMarkdownViewTest: View {
#if canImport(UIKit)
    private typealias PlatformImage = UIImage
#elseif canImport(AppKit)
    private typealias PlatformImage = NSImage
#endif
    
    private let document = try! MarkdownDocument( // swiftlint:disable:this force_try
        processing: """
            ---
            title: Welcome to the Spezi Ecosystem
            date: 2025-06-22T14:41:16+02:00
            ---
            
            # Welcome to the Spezi Ecosystem
            This article aims to provide you with a broad overview of Spezi.
            
            <marquee filename="PM5544.png" period=5 />
            
            ## Our Modules
            Spezi is architected to be a highly modular system, allowing your application to ...
            
            ### SpeziHealthKit
            text text text
            """,
        customElementNames: ["marquee"]
    )
    
    var body: some View {
        ScrollView {
            MarkdownView(
                markdownDocument: document,
                dividerRule: .init { blockIdx, block in
                    block.isCustomElement || (block.isMarkdown && document.blocks[safe: blockIdx + 1]?.isMarkdown == false)
                }
            ) { _, element in
                switch element.name {
                case "marquee":
                    if let filename = element[attribute: "filename"],
                       let image = loadPlatformImage(named: filename),
                       let period = element[attribute: "period"].flatMap({ TimeInterval($0) }) {
                        Marquee(period: period) {
                            #if canImport(UIKit)
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: image.size.width * (52 / image.size.height), height: 52)
                            #elseif canImport(AppKit)
                            Image(nsImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: image.size.width * (52 / image.size.height), height: 52)
                            #else
                            EmptyView()
                            #endif
                        }
                        .accessibilityElement()
                        .accessibilityIdentifier("ayooooooo")
                    }
                default:
                    EmptyView()
                }
            }
            .padding(.horizontal)
        }
        .toolbar {
            if let title = document.metadata.title {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(title)
                            .font(.headline)
                        if let date = document.metadata["date"].flatMap({ try? Date($0, strategy: .iso8601) }) {
                            Text(date, format: .dateTime.year().month().day().hour(.defaultDigits(amPM: .abbreviated)).minute())
                                .font(.subheadline)
                                .environment(\.timeZone, .losAngeles)
                                .environment(\.locale, Locale(identifier: "en_US"))
                        }
                    }
                }
            }
        }
    }
    
    
    private func loadPlatformImage(named name: String) -> PlatformImage? {
        #if canImport(UIKit)
        return UIImage(named: name)
        #elseif canImport(AppKit)
        return NSImage(named: NSImage.Name(name))
        #else
        return nil
        #endif
    }
}


private struct Marquee<Content: View>: View {
    /// how many seconds a full left-right movement corresponds to
    let period: TimeInterval
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
        let distance = sin((progress / period) * .pi)
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


extension MarkdownDocument.Block {
    var isMarkdown: Bool {
        switch self {
        case .markdown: true
        case .customElement: false
        }
    }
    
    var isCustomElement: Bool {
        switch self {
        case .markdown: false
        case .customElement: true
        }
    }
}
