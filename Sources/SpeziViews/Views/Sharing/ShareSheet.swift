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
    /// Presents the system share sheet.
    ///
    /// On iOS, the `items` binding is set to an empty array upon dismissal of the share sheet.
    /// On macOS, the binding is reset to an empty array immediately after presenting the share sheet.
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
            if !combinedInput.isEmpty {
                let shareSheet = AppKitShareSheet(items: combinedInput)
                shareSheet.show()
                items.wrappedValue = []
            }
        }
        #endif
    }
}
