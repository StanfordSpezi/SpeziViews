//
// This source file is part of the Stanford Spezi open-project
//
// SPDX-FileCopyrightText: 2024 Stanford University
//
// SPDX-License-Identifier: MIT
//

import SwiftUI


/// Reference an Image Resource.
public enum ImageReference {
    /// Provides the system name for an image.
    case system(String)
    /// Reference an image from the asset catalog of a bundle.
    case asset(String, bundle: Bundle? = nil)


    /// A system image is referenced.
    public var isSystemImage: Bool {
        if case .system = self {
            true
        } else {
            false
        }
    }
}


extension ImageReference {
    /// Retrieve Image.
    ///
    /// Returns `nil` if the image resource could not be located.
    public var image: Image? {
        switch self {
        case let .system(name):
            return Image(systemName: name)
        case let .asset(name, bundle: bundle):
#if canImport(UIKit)
            // also available on watchOS
            guard UIImage(named: name, in: bundle, with: nil) != nil else {
                return nil
            }
#elseif canImport(AppKit)
            guard NSImage(named: name) != nil else {
                return nil
            }
#endif
            return Image(name, bundle: bundle)
        }
    }

#if canImport(UIKit) // also available on watchOS
    /// Retrieve an UIImage.
    ///
    /// Returns `nil` if the image resource could not be located.
    public var uiImage: UIImage? {
        switch self {
        case let .system(name):
            UIImage(systemName: name)
        case let .asset(name, bundle):
            UIImage(named: name, in: bundle, with: nil)
        }
    }

#if canImport(WatchKit)
    /// Retrieve a WKImage.
    ///
    /// Returns `nil` if the image resource could not be located.
    public var wkImage: WKImage? {
        uiImage.map { WKImage(image: $0) }
    }
#endif
#elseif canImport(AppKit)
    /// Retrieve a NSImage.
    ///
    /// Returns `nil` if the image resource could not be located.
    public var uiImage: NSImage? {
        switch self {
        case let .system(name):
            NSImage(systemSymbolName: name, accessibilityDescription: nil)
        case let .asset(name, _):
            NSImage(named: name)
        }
    }
#endif
}


extension ImageReference: Hashable, Sendable {}
