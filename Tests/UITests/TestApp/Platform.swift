//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

#if canImport(UIKit)
import UIKit
typealias UINSColor = UIColor
typealias UINSImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias UINSColor = NSColor
typealias UINSImage = NSImage
#endif
