//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation
import PhotosUI
import SpeziViews
import SwiftUI
import UniformTypeIdentifiers


struct FilePickerTestView: View {
    @State private var allowedContentTypes: Set<UTType> = []
    @State private var allowMultipleSelection = true
    @State private var items: [_FilePickerItem] = []
    
    var body: some View {
        Form {
            Section {
                Toggle("Allow Multiple Selection", isOn: $allowMultipleSelection)
                allowedContentTypesPicker
            }
            Section {
                ForEach(items, id: \.self) { item in
                    row(for: item)
                }
                _FilePicker(allowedContentTypes, allowMultipleSelection: allowMultipleSelection) { items in
                    Task { @MainActor in
                        for item in items {
                            if !self.items.contains(item) {
                                self.items.append(item)
                            }
                        }
                    }
                } label: { suggestedTitle in
                    _ListRowFilePickerLabel(suggestedTitle)
                }

            }
        }
    }
    
    private var allowedContentTypesPicker: some View {
        NavigationLink {
            Form {
                let types: [UTType] = [
                    .data, .item, .image, .pdf, .tiff, .movie, .video
                ]
                ForEach(types, id: \.self) { type in
                    Button {
                        if allowedContentTypes.contains(type) {
                            allowedContentTypes.remove(type)
                        } else {
                            allowedContentTypes.insert(type)
                        }
                    } label: {
                        HStack {
                            Text(type.displayTitle)
                            Spacer()
                            if allowedContentTypes.contains(type) {
                                Image(systemName: "checkmark")
                                    .accessibilityHidden(true)
                            }
                        }
                    }
                }
            }
        } label: {
            LabeledContent(
                "Allowed Content Types",
                value: allowedContentTypes.map(\.displayTitle).sorted().joined(separator: ", ")
            )
        }
    }
    
    @ViewBuilder
    private func row(for item: _FilePickerItem) -> some View {
        switch item {
        case .file(let url):
            HStack {
                FileThumbnail(url)
                VStack(alignment: .leading) {
                    let fileInfo = url.fileInfo()
                    Text(url.lastPathComponent)
                    Text({ () -> String in
                        var elements: [String] = []
                        if let uti = fileInfo.uti {
                            // TODO how can we get smth like "TIFF Image" (ie what the system share sheet does)
                            elements.append(uti.description)
                        }
                        if let size = fileInfo.size {
                            elements.append(Int64(size).formatted(.byteCount(style: .file, spellsOutZero: true)))
                        }
                        return elements.joined(separator: " • ")
                    }())
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
            }
        case .photo(let item):
            HStack {
                PhotosPickerItemThumbnail(item: item)
                    .frame(height: 50)
                Text("Selected Image")
                Spacer()
            }
        }
    }
}


extension FilePickerTestView {
    private struct PhotosPickerItemThumbnail: View {
        let item: PhotosPickerItem
        @State private var image: Image?
        
        var body: some View {
            VStack {
                if let image {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .task(id: item) {
                image = try? await item.loadTransferable(type: Image.self)
            }
        }
    }
}


extension UTType {
    fileprivate var displayTitle: String {
        localizedDescription ?? identifier
    }
}


extension URL {
    fileprivate struct FileInfo {
        let size: Int?
        let uti: UTType?
    }
    
    fileprivate func fileInfo() -> FileInfo {
        let resourceValues = (try? self.resourceValues(forKeys: [.fileSizeKey])) ?? URLResourceValues()
        return FileInfo(
            size: resourceValues.fileSize,
            uti: UTType(filenameExtension: self.pathExtension)
        )
    }
}
