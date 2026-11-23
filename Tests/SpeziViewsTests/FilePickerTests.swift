//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !os(tvOS) && !os(watchOS)

@testable import SpeziViews
import Testing
import UniformTypeIdentifiers


struct FilePickerTests {
    struct Case: Sendable, CustomTestStringConvertible {
        let allowedContentTypes: Set<UTType>
        let expected: FilePickerPhotoLibraryContent
        
        var testDescription: String {
            allowedContentTypes.map(\.identifier).sorted().joined(separator: ", ")
        }
    }
    
    static let cases: [Case] = [
        Case(allowedContentTypes: [.data], expected: [.images, .videos]),
        Case(allowedContentTypes: [.item], expected: [.images, .videos]),
        Case(allowedContentTypes: [.image], expected: [.images]),
        Case(allowedContentTypes: [.movie], expected: [.videos]),
        Case(allowedContentTypes: [.audiovisualContent], expected: [.videos]),
        Case(allowedContentTypes: [.image, .pdf], expected: [.images]),
        Case(allowedContentTypes: [.image, .movie], expected: [.images, .videos]),
        // Specific formats: the photo library may return items in other formats, so it isn't offered.
        Case(allowedContentTypes: [.png], expected: []),
        Case(allowedContentTypes: [.jpeg, .tiff], expected: []),
        Case(allowedContentTypes: [.mpeg4Movie], expected: []),
        Case(allowedContentTypes: [.pdf], expected: [])
    ]
    
    @Test(arguments: cases)
    func photoLibraryContent(_ testCase: Case) {
        #expect(FilePickerPhotoLibraryContent(allowedContentTypes: testCase.allowedContentTypes) == testCase.expected)
    }
}

#endif
