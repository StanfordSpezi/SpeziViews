//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(AppKit)
import AppKit
#elseif canImport(UIKit)
import UIKit
#endif
import Foundation
import SwiftUI


#if canImport(UIKit) && !os(watchOS)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
@MainActor
private struct UIKitShareSheet: UIViewControllerRepresentable {
    let input: CombinedShareSheetInput
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(
            activityItems: input.inputs.map { $0.representationForSharing },
            applicationActivities: nil
        )
    }

    func updateUIViewController(_ controller: UIActivityViewController, context: Context) {
        // intentionally doesn't update the items.
    }
}
#elseif canImport(AppKit)
@MainActor
private struct AppKitShareSheet {
    let items: CombinedShareSheetInput
    
    func show() {
        let sharingServicePicker = NSSharingServicePicker(
            items: items.inputs.map(\.representationForSharing)
        )
        // Present the sharing service picker
        if let keyWindow = NSApp.keyWindow, let contentView = keyWindow.contentView {
            sharingServicePicker.show(relativeTo: contentView.bounds, of: contentView, preferredEdge: .minY)
        }
    }
}
#endif


extension View {
    /// Share an item using the system share sheet.
    ///
    /// On iOS, the `item` binding is set to `nil` upon dismissal of the share sheet.
    /// On macOS, the binding is set to `nil` immediately after presenting the share sheet.
    ///
    /// ## Topics
    /// - ``ShareSheetInput``
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @ViewBuilder
    public func shareSheet(item: Binding<ShareSheetInput?>) -> some View {
        self.shareSheet(items: Binding<[ShareSheetInput]> {
            if let item = item.wrappedValue {
                [item]
            } else {
                []
            }
        } set: { newValue in
            item.wrappedValue = newValue.first
        })
    }
    
    
    /// Share multiple items using the system share sheet.
    ///
    /// On iOS, the `items` binding is set to an empty array upon dismissal of the share sheet.
    /// On macOS, the binding is reset to an empty array immediately after presenting the share sheet.
    ///
    /// - Note: This API serves as an alternative to SwiftUI's `ShareLink`, and can, in some edge cases, provide a better user experience.
    ///     Always try using a `ShareLink` first and only use this API if you found the `ShareLink`'s capabilities lacking for your specific use case.
    ///     If you just want to share a URL, a String, or a file that already exists on disk, the `ShareLink` is probably the preferable option.
    ///
    /// Differences to SwiftUI's `ShareLink`:
    /// - You can control the presentation of the share sheet via a Binding, rather than having it presented in response to the user tapping the `ShareLink`'s internal Button.
    ///     This allows you to e.g. present the share sheet only conditionally, and in response to / depending on complex logic.
    /// - For some inputs (e.g. `PDFDocument`s), the `ShareLink` defers the creation of the actual shared resource until the user actually selects a sharing destination in the share sheet,
    ///     resulting in the share sheet's header being empty (since the information simply isn't available yet).
    ///     The share sheet presented by this API doesn't defer this operation, and as a result is able to always display these metadata.
    /// - Using the `ShareLink` on macOS will result in an empty share sheet for certain inputs; this API will present a properly populated share sheet for the same inputs.
    ///
    /// ## Topics
    /// - ``ShareSheetInput``
    @available(tvOS, unavailable)
    @available(watchOS, unavailable)
    @ViewBuilder
    public func shareSheet(items: Binding<[ShareSheetInput]>) -> some View {
        #if canImport(UIKit) && !os(watchOS)
        let binding = Binding<CombinedShareSheetInput?> {
            items.isEmpty ? nil : CombinedShareSheetInput(inputs: items.wrappedValue)
        } set: { newValue in
            if let newValue {
                items.wrappedValue = newValue.inputs
            } else {
                items.wrappedValue = []
            }
        }
        self.sheet(item: binding) { combinedInput in
            UIKitShareSheet(input: combinedInput)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.hidden)
        }
        #elseif canImport(AppKit)
        let combinedInput = CombinedShareSheetInput(inputs: items.wrappedValue)
        self.onChange(of: combinedInput) {
            if !combinedInput.inputs.isEmpty {
                let shareSheet = AppKitShareSheet(items: combinedInput)
                shareSheet.show()
                items.wrappedValue = []
            }
        }
        #endif
    }
}
