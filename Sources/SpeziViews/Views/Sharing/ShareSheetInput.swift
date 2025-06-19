//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

// swiftlint:disable file_types_order

import Foundation
#if !os(watchOS)
import class PDFKit.PDFDocument
#endif


/// Marker protocol that indicates that a type can be directly passed into a `UIActivityViewController`, without having to go through a `NSItemProvider`.
@_marker
public protocol HasDirectUIActivityViewControllerSupport {}
extension String: HasDirectUIActivityViewControllerSupport {}
extension URL: HasDirectUIActivityViewControllerSupport {}


/// An Array of ``ShareSheetInput`` values, providing `Identifiable` and `Equatable` conformances for SwiftUI integration.
struct CombinedShareSheetInput: Identifiable, Equatable {
    /// A stable identifier, computed by combining the identifiers of the individual inputs.
    let id: AnyHashable
    let inputs: [ShareSheetInput]
    
    init(inputs: [ShareSheetInput]) {
        self.inputs = inputs
        self.id = AnyHashable(inputs.map(\.id))
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}


/// A value that should be shared using the system share sheet.
///
/// ## Topics
/// ### Initializers
/// - ``init(_:)-(HasDirectUIActivityViewControllerSupportHashable)``
/// - ``init(_:id:)``
/// - ``init(_:)-(NSItemProviderWriting)``
/// - ``init(_:)-(T)``
/// - ``init(_:)-(PDFDocument)``
/// - ``init(verbatim:id:)``
///
/// ### Supporting Types
/// - ``HasDirectUIActivityViewControllerSupport``
public struct ShareSheetInput {
    let id: AnyHashable
    let representationForSharing: Any
    
    private init(id: AnyHashable, itemProvider: NSItemProvider) {
        self.id = id
        self.representationForSharing = itemProvider
    }
    
    private init(id: AnyHashable, representationForSharing: Any) {
        self.id = id
        self.representationForSharing = representationForSharing
    }
}


extension ShareSheetInput {
    /// Creates a new `ShareSheetInput`.
    public init(_ input: some HasDirectUIActivityViewControllerSupport & Hashable) {
        self.init(input, id: \.self)
    }
    
    /// Creates a new `ShareSheetInput`.
    public init<Input>(_ input: Input, id: (Input) -> some Hashable) where Input: HasDirectUIActivityViewControllerSupport {
        self.init(id: AnyHashable(id(input)), representationForSharing: input)
    }
    
    /// Creates a new `ShareSheetInput`, for sharing an `NSItemProviderWriting`-conforming value
    public init(_ input: some NSItemProviderWriting) {
        self.init(
            id: ObjectIdentifier(input),
            itemProvider: NSItemProvider(object: input)
        )
    }
    
    /// Creates a new `ShareSheetInput`, for sharing an `NSItemProviderWriting`-conforming value
    @_disfavoredOverload
    public init<T>(_ input: T) where T: _ObjectiveCBridgeable, T._ObjectiveCType: NSItemProviderWriting {
        self.init(input._bridgeToObjectiveC())
    }
    
    #if !os(watchOS)
    /// Creates a new `ShareSheetInput`, for sharing a `PDFDocument`
    public init(_ input: PDFDocument) {
        self.init(ShareableRepresentation(pdf: input))
    }
    #endif
    
    /// Creates a new `ShareSheetInput`.
    ///
    /// This initializer will cause the `input` value to get directly passe on to `UIActivityViewController` on iOS and `NSSharingServicePicker` on macOS,
    /// without performing any processing or transformation based on the specific input type.
    ///
    /// - Note: Only use this initializer if you know for a fact that `Input` is compatible with the system share sheet.
    public init<Input>(verbatim input: Input, id: (Input) -> some Hashable) {
        self.init(id: id(input), representationForSharing: input)
    }
}
