//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(QuickLookThumbnailing)

import Foundation
import QuickLookThumbnailing
import SwiftUI

#if canImport(UIKit)
private typealias PlatformImage = UIImage
#else
private typealias PlatformImage = NSImage
#endif


/// An `Image` displaying a thumbnail for a file at a `URL`.
///
/// The view is empty until the thumbnail has been generated, and stays empty if no thumbnail can be generated for the file.
///
/// - Note: Not available on tvOS and watchOS.
public struct FileThumbnail: View {
    @Environment(\.displayScale) private var scale
    private let url: URL
    private let size: CGSize
    private let representationTypes: QLThumbnailGenerator.Request.RepresentationTypes
    @State private var image: PlatformImage?

    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        VStack {
            if let image {
                #if canImport(UIKit)
                Image(uiImage: image)
                    .accessibilityHidden(true)
                #else
                Image(nsImage: image)
                    .accessibilityHidden(true)
                #endif
            }
        }
        .task(id: url) {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: size,
                scale: scale,
                representationTypes: representationTypes
            )
            guard let thumbnail = try? await QLThumbnailGenerator.shared.generateBestRepresentation(for: request) else {
                image = nil
                return
            }
            #if canImport(UIKit)
            image = thumbnail.uiImage
            #else
            image = thumbnail.nsImage
            #endif
        }
    }

    /// Creates a file thumbnail view for a URL.
    ///
    /// - Parameters:
    ///   - url: The file URL.
    ///   - size: The maximum size of the thumbnail, in points.
    ///   - representationTypes: The kinds of thumbnails that may be generated.
    public init(
        _ url: URL,
        size: CGSize = CGSize(width: 50, height: 50),
        representationTypes: QLThumbnailGenerator.Request.RepresentationTypes = .all
    ) {
        self.url = url
        self.size = size
        self.representationTypes = representationTypes
    }
}

#endif
