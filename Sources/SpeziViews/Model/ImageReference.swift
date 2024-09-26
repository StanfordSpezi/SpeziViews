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
#if os(iOS) || os(visionOS) || os(tvOS)
            guard UIImage(named: name, in: bundle, with: nil) != nil else {
                return nil
            }
#elseif os(macOS)
            guard NSImage(named: name) != nil else {
                return nil
            }
#endif
            return Image(name, bundle: bundle)
        }
    }
    
    /// Retrieve the UIImage.
    ///
    /// Returns `nil` if the image resource could not be located.
    @available(iOS 17, visionOS 1, tvOS 17, *)
    public func uiImage(with configuration: UIImage.Configuration? = nil) -> UIImage? {
        switch self {
        case let .system(name):
            UIImage(systemName: name, withConfiguration: configuration)
        case let .asset(name, bundle):
            UIImage(named: name, in: bundle, with: configuration)
        }
    }
}


extension ImageReference: Hashable, Sendable {}
