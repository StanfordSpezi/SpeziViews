//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(PencilKit)
import PencilKit

extension PKDrawing: @retroactive Hashable {
    public func hash(into hasher: inout Hasher) {
        if #available(iOS 18, macOS 15, visionOS 2, *) {
            hasher.combine(self.bounds)
        } else {
            let bounds = self.bounds
            hasher.combine(bounds.origin.x)
            hasher.combine(bounds.origin.y)
            hasher.combine(bounds.size.width)
            hasher.combine(bounds.size.height)
        }
        hasher.combine(self.strokes.count)
    }
}

extension PKDrawing {
    /// Whether the drawing contains no strokes, or whether all of the drawing's strokes consist of empty paths.
    @inlinable public var isEmpty: Bool {
        strokes.allSatisfy(\.path.isEmpty)
    }
}

#endif
