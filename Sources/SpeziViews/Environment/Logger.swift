//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import OSLog
import SwiftUI

/// An `EnvironmentKey` to be used for providing a specific `Logger` object to subviews.
///
/// This might be useful to provide a logger to generic subviews depending on the context they are being used in.
private struct LoggerKey: EnvironmentKey {
    static let defaultValue: Logger = .init()
}

extension EnvironmentValues {
    /// A `Logger` to be used when logging capabilities are required.
    ///
    /// This might be useful to provide a logger to generic subviews depending on the context they are being used in.
    public var logger: Logger {
        get {
            self[LoggerKey.self]
        }
        set {
            self[LoggerKey.self] = newValue
        }
    }
}
