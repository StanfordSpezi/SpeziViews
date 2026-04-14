//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import PhotosUI
import SpeziFoundation
import SwiftUI
import UniformTypeIdentifiers


/// An item that was selected using the ``_FilePicker``
public enum _FilePickerItem: Sendable, Hashable { // swiftlint:disable:this type_name
    case file(URL)
    case photo(PhotosPickerItem)
}


/// Reusable view that offers file import options from a range of sources.
@available(watchOS, unavailable)
public struct _FilePicker<Label: View>: View { // swiftlint:disable:this type_name
    @Environment(\.isEnabled) private var isEnabled
    private let label: @MainActor (_ suggestedTitle: LocalizedStringResource) -> Label
    private let enabledTypes: Set<UTType>
    private let allowMultipleSelection: Bool
    private let selectionHandler: @Sendable ([_FilePickerItem]) -> Void
    @State private var isShowingPhotosPicker = false
    @State private var isShowingFileImporter = false
    @State private var isShowingCameraSheet = false
    @State private var viewState: ViewState = .idle
    @State private var selectedPhotos: [PhotosPickerItem] = []
    
    public var body: some View {
        // IDEAS
        // - if there is only one enabled uti, we should skip the menu!
        // - if there are no enabled UTIs, we show the regular menu, but disable it!
        Menu {
            importMenuContents
        } label: {
            label(suggestedTitle)
        }
        .accessibilityIdentifier("FilePickerButton")
        .listRowInsets(EdgeInsets())
        .viewStateAlert(state: $viewState)
        // We need all of these modifiers placed here at the top level, since the buttons that trigger them are in the Menu,
        // and will disappear when tapped (bc the menu gets closed)
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $selectedPhotos,
            // Issue (here and below) what if the user already has selected an image, and is now also opening the file picker?
            // in a single-selection scenario, we'd either need to remove the image, or disable the file picker.
            maxSelectionCount: allowMultipleSelection ? nil : 1,
            selectionBehavior: .default,
            matching: { () -> PHPickerFilter in
                let enabledTypes: [PHPickerFilter] = Array {
                    if shouldEnable(.movie) {
                        .videos
                    }
                    if shouldEnable(.image) {
                        // QUESTION if the user has live photos enabled, would this filter only photos w/out a live photo attached,
                        // or would it still include everything?
                        .images
                    }
                }
                // can't have an empty ANY filter
                return enabledTypes.isEmpty ? .images : .any(of: enabledTypes)
            }(),
            preferredItemEncoding: .automatic
        )
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: Array(enabledTypes),
            allowsMultipleSelection: allowMultipleSelection
        ) { result in
            switch result {
            case .success(let urls):
                selectionHandler(urls.map { .file($0) })
            case .failure(let error):
                viewState = .error(AnyLocalizedError(error: error))
            }
        }
        .sheet(isPresented: $isShowingCameraSheet) {
            Text("Not Yet Implemented", bundle: .module)
        }
        .onChange(of: selectedPhotos) { _, newValue in
            guard !newValue.isEmpty else {
                return
            }
            // it seems that the PhotosPicker only updates the binding, once, at the end, when the user confirmed the selection.
            // if multiple selection is enabled, the binding does not get continuously updated as the selection changes.
            let photos = exchange(&selectedPhotos, with: [])
            selectionHandler(photos.map { .photo($0) })
        }
    }
    
    private var suggestedTitle: LocalizedStringResource {
        if enabledTypes.allSatisfy({ $0.conforms(to: .image) }) {
            if allowMultipleSelection {
                LocalizedStringResource("Select Images", bundle: .module)
            } else {
                LocalizedStringResource("Select Image", bundle: .module)
            }
        } else if enabledTypes.allSatisfy({ $0.conforms(to: .movie) }) {
            if allowMultipleSelection {
                LocalizedStringResource("Select Videos", bundle: .module)
            } else {
                LocalizedStringResource("Select Video", bundle: .module)
            }
        } else {
            if allowMultipleSelection {
                LocalizedStringResource("Select Files", bundle: .module)
            } else {
                LocalizedStringResource("Select File", bundle: .module)
            }
        }
    }
    
    @ViewBuilder private var importMenuContents: some View {
        if shouldEnable(.image) || shouldEnable(.movie) {
            selectPhotosButton
            Divider()
        }
        importFileButton
    }
    
    private var selectPhotosButton: some View {
        Button {
            isShowingPhotosPicker = true
        } label: {
            SwiftUI.Label(LocalizedStringResource("Select Photo", bundle: .module), systemImage: "photo.on.rectangle")
        }
    }
    
    private var importFileButton: some View {
        Button {
            isShowingFileImporter = true
        } label: {
            SwiftUI.Label(LocalizedStringResource("Select File", bundle: .module), systemImage: "document")
        }
    }
    
    public init(
        _ contentTypes: Set<UTType>,
        allowMultipleSelection: Bool,
        selectionHandler: @escaping @Sendable ([_FilePickerItem]) -> Void,
        @ViewBuilder label: @escaping @MainActor (_ suggestedTitle: LocalizedStringResource) -> Label
    ) {
        self.enabledTypes = contentTypes.isEmpty ? [.data] : contentTypes
        self.allowMultipleSelection = allowMultipleSelection
        self.selectionHandler = selectionHandler
        self.label = label
    }
    
    private func shouldEnable(_ uti: UTType) -> Bool {
        enabledTypes.contains { $0.isCompatible(with: uti) }
    }
}


public struct _ListRowFilePickerLabel: View { // swiftlint:disable:this type_name
    private let title: Text
    
    public var body: some View {
        HStack {
            Image(systemName: "plus.circle.fill")
                .foregroundStyle(.green)
                .accessibilityHidden(true)
            title
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .foregroundStyle(.secondary)
                .accessibilityHidden(true)
        }
        .contentShape(Rectangle())
        .frame(maxHeight: .infinity)
        .padding()
    }
    
    public init(_ title: LocalizedStringResource) {
        self.title = Text(title)
    }
    
    public init(_ title: some StringProtocol) {
        self.title = Text(title)
    }
}


extension UTType {
    // we have the bidirectional check here, because:
    // - if the FilePicker is allowed to select `UTType.image`s we obviously want to allow it to ONLY pick images; but
    // - if its set to `UTType.data` or `.image`, we want to allow it to pick
    fileprivate func isCompatible(with other: Self) -> Bool {
        self.conforms(to: other) || other.conforms(to: self)
    }
}
