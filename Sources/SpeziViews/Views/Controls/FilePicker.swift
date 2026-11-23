//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if !os(tvOS) && !os(watchOS)

// swiftlint:disable file_types_order

import PhotosUI
import SpeziFoundation
import SwiftUI
import UniformTypeIdentifiers


/// An item that was selected using a ``FilePicker``.
public enum FilePickerItem: Sendable, Hashable {
    /// A file selected from the Files app.
    ///
    /// - Note: The URL may point to a security-scoped resource. Call `startAccessingSecurityScopedResource()`
    ///     before reading it, and `stopAccessingSecurityScopedResource()` once you are done.
    case file(URL)
    /// A photo or video selected from the photo library.
    case photo(PhotosPickerItem)
}


/// A menu that lets the user pick files, photos, or videos.
///
/// Depending on the allowed content types, the menu offers to select items from the photo library, from the Files app, or both.
///
/// ```swift
/// FilePicker([.image, .pdf], allowMultipleSelection: true) { items in
///     // handle the selected items ...
/// } label: { suggestedTitle in
///     FilePickerListRowLabel(suggestedTitle)
/// }
/// ```
///
/// The `label` closure receives a suggested title (e.g., "Select Images" or "Select File") based on the allowed content types,
/// which you can use for the menu's label.
///
/// - Note: Not available on tvOS and watchOS.
public struct FilePicker<Label: View>: View {
    private let label: @MainActor (_ suggestedTitle: LocalizedStringResource) -> Label
    private let enabledTypes: Set<UTType>
    private let allowMultipleSelection: Bool
    private let selectionHandler: @MainActor ([FilePickerItem]) -> Void
    @State private var isShowingPhotosPicker = false
    @State private var isShowingFileImporter = false
    @State private var viewState: ViewState = .idle
    @State private var selectedPhotos: [PhotosPickerItem] = []

    @_documentation(visibility: internal) // swiftlint:disable:next attributes
    public var body: some View {
        Menu {
            if shouldEnable(.image) || shouldEnable(.movie) {
                selectPhotosButton
                Divider()
            }
            importFileButton
        } label: {
            label(suggestedTitle)
        }
        .accessibilityIdentifier("FilePickerButton")
        .listRowInsets(EdgeInsets())
        .viewStateAlert(state: $viewState)
        // The modifiers that present the pickers need to be placed at the top level,
        // since the buttons that trigger them are in the Menu, which gets dismissed when a button is tapped.
        .photosPicker(
            isPresented: $isShowingPhotosPicker,
            selection: $selectedPhotos,
            maxSelectionCount: allowMultipleSelection ? nil : 1,
            selectionBehavior: .default,
            matching: photosPickerFilter,
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
        .onChange(of: selectedPhotos) { _, newValue in
            guard !newValue.isEmpty else {
                return
            }
            // The PhotosPicker updates the binding once, when the user confirms the selection.
            let photos = exchange(&selectedPhotos, with: [])
            selectionHandler(photos.map { .photo($0) })
        }
    }

    private var suggestedTitle: LocalizedStringResource {
        let key: String.LocalizationValue
        if enabledTypes.allSatisfy({ $0.conforms(to: .image) }) {
            key = allowMultipleSelection ? "Select Images" : "Select Image"
        } else if enabledTypes.allSatisfy({ $0.conforms(to: .movie) }) {
            key = allowMultipleSelection ? "Select Videos" : "Select Video"
        } else {
            key = allowMultipleSelection ? "Select Files" : "Select File"
        }
        return LocalizedStringResource(key, bundle: .atURL(from: .module))
    }
    
    private var photosPickerFilter: PHPickerFilter {
        let filters: [PHPickerFilter] = Array {
            if shouldEnable(.movie) {
                .videos
            }
            if shouldEnable(.image) {
                .images
            }
        }
        // an `any(of:)` filter can't be empty
        return filters.isEmpty ? .images : .any(of: filters)
    }

    private var selectPhotosButton: some View {
        Button {
            isShowingPhotosPicker = true
        } label: {
            SwiftUI.Label(LocalizedStringResource("Photo Library", bundle: .atURL(from: .module)), systemImage: "photo.on.rectangle")
        }
    }

    private var importFileButton: some View {
        Button {
            isShowingFileImporter = true
        } label: {
            SwiftUI.Label(LocalizedStringResource("Browse Files", bundle: .atURL(from: .module)), systemImage: "folder")
        }
    }

    /// Creates a file picker.
    ///
    /// - Parameters:
    ///   - contentTypes: The content types the user may select. If empty, any data can be selected.
    ///   - allowMultipleSelection: Whether the user may select multiple items at once.
    ///   - selectionHandler: Called with the selected items once the user confirms a selection.
    ///   - label: The menu's label. The closure receives a suggested title based on the allowed content types.
    public init(
        _ contentTypes: Set<UTType>,
        allowMultipleSelection: Bool,
        selectionHandler: @escaping @MainActor ([FilePickerItem]) -> Void,
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


/// A list row label for a ``FilePicker``.
///
/// ```swift
/// FilePicker([.pdf], allowMultipleSelection: false) { items in
///     // handle the selected items ...
/// } label: { suggestedTitle in
///     FilePickerListRowLabel(suggestedTitle)
/// }
/// ```
public struct FilePickerListRowLabel: View {
    private let title: Text

    @_documentation(visibility: internal) // swiftlint:disable:next attributes
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

    /// Creates a list row label with a localized title.
    public init(_ title: LocalizedStringResource) {
        self.title = Text(title)
    }

    /// Creates a list row label with a title.
    @_disfavoredOverload
    public init(_ title: some StringProtocol) {
        self.title = Text(title)
    }
}


extension UTType {
    /// Whether two types overlap, in either direction.
    ///
    /// A picker that allows `.image` should offer the photo library, and so should a picker that allows any `.data`,
    /// since images are data as well.
    fileprivate func isCompatible(with other: Self) -> Bool {
        self.conforms(to: other) || other.conforms(to: self)
    }
}

#endif
