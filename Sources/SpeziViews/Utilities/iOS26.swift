//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Foundation


extension ProcessInfo {
    static let isIOS26 = ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
}
