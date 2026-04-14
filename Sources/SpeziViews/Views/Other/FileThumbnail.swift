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


/// An `Image` displaying a thumbnail for a file at a `URL`.
///
/// - Note: Not available on watchOS.
public struct FileThumbnail: View {
    @Environment(\.displayScale) private var scale
    private let url: URL
    private let size: CGSize
    private let representationTypes: QLThumbnailGenerator.Request.RepresentationTypes
    @State private var image: UIImage?
    
    public var body: some View {
        VStack {
            if let image {
                Image(uiImage: image)
                    .accessibilityHidden(true)
            }
        }
        .task(id: url) {
            let request = QLThumbnailGenerator.Request(
                fileAt: url,
                size: size,
                scale: scale,
                representationTypes: representationTypes
            )
            let generator = QLThumbnailGenerator.shared
            guard let thumbnail = try? await generator.generateBestRepresentation(for: request) else {
                return
            }
            self.image = thumbnail.uiImage
        }
    }
    
    /// Creates a file thumbnail view for a URL.
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
