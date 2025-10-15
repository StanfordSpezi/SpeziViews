//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import MarkdownUI
import SwiftUI


struct MarkdownViewImageProvider: ImageProvider {
    private struct ImageLoadingView: View {
        let url: URL?
        @State private var image: Image?
        
        var body: some View {
            ResizeToFit {
                if let image {
                    image.resizable()
                }
            }
            .task {
                if let url {
                    image = try? await CachedImageLoader.shared.load(url)
                }
            }
        }
    }
    
    func makeImage(url: URL?) -> some View {
        ImageLoadingView(url: url)
    }
}


struct MarkdownViewInlineImageProvider: InlineImageProvider {
    func image(with url: URL, label: String) async throws -> Image {
        try await CachedImageLoader.shared.load(url)
    }
}


private actor CachedImageLoader {
    enum LoadError: Error {
        case unableToDecode
    }
    
    static let shared = CachedImageLoader()
    
    private let urlSession: URLSession
    private var cache: [URL: Image] = [:]
    
    init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.httpAdditionalHeaders = ["Accept": "image/*"]
        config.requestCachePolicy = .returnCacheDataElseLoad
        let oneMB = 1024 * 1024
        config.urlCache = URLCache(
            memoryCapacity: 50 * oneMB,
            diskCapacity: 250 * oneMB
        )
        urlSession = URLSession(configuration: config)
    }
    
    func load(_ url: URL) async throws -> Image {
        if let image = cache[url] {
            return image
        } else {
            let data = try await urlSession.data(from: url).0
            #if canImport(UIKit)
            let image = UIImage(data: data)
            #elseif canImport(AppKit)
            let image = NSImage(data: data)
            #endif
            guard let image, case let image = Image(image) else {
                throw LoadError.unableToDecode
            }
            cache[url] = image
            return image
        }
    }
}


extension Image {
    #if canImport(UIKit)
    init(_ platformImage: UIImage) {
        self.init(uiImage: platformImage)
    }
    #elseif canImport(AppKit)
    init(_ platformImage: NSImage) {
        self.init(nsImage: platformImage)
    }
    #endif
}
