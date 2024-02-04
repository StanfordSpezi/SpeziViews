//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import SwiftUI

#if os(watchOS)
/// TextContentType typealias that is platform-agnostic.
///
/// This typealias points to [`WKTextContentType`](https://developer.apple.com/documentation/watchkit/wktextcontenttype) from WatchKit.
public typealias TextContentType = WKTextContentType // swiftlint:disable:this file_types_order
#elseif os(macOS)
/// TextContentType typealias that is platform-agnostic.
///
/// This typealias points to [`NSTextContentType`](https://developer.apple.com/documentation/appkit/nstextcontenttype) from AppKit.
public typealias TextContentType = NSTextContentType
#else
/// TextContentType typealias that is platform-agnostic.
///
/// This typealias points to [`UITextContentType`](https://developer.apple.com/documentation/uikit/uitextcontenttype) from UIKit.
public typealias TextContentType = UITextContentType
#endif
