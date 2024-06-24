//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2024 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
@_spi(TestingSupport) import SpeziFoundation
import TipKit


/// Configure TipKit.
///
/// This module allows to easily and globally configure TipKit by calling `Tips/configure(_:)`.
/// You can use the Spezi Dependency system to require TipKit to be configured or can use the `@Environment` property wrapper in your
/// SwiftUI views to verify that TipKit was configured when using TipKit-based View components.
public class ConfigureTipKit: Module, DefaultInitializable, EnvironmentAccessible {
    private let configuration: [Tips.ConfigurationOption]

    @Application(\.logger) private var logger


    /// Configure TipKit.
    /// - Parameter configuration: TipKit configuration options.
    public init(_ configuration: [Tips.ConfigurationOption]) {
        self.configuration = configuration
    }

    /// Configure TipKit with default options.
    public required convenience init() {
        self.init([])
    }

    public func configure() {
        if RuntimeConfig.testingTips || ProcessInfo.processInfo.isPreviewSimulator {
            Tips.showAllTipsForTesting()
        }
        do {
            try Tips.configure(configuration)
        } catch {
            logger.error("Failed to configure TipKit: \(error)")
        }
    }
}


extension RuntimeConfig {
    /// Enable testing tips
    @_spi(TestingSupport)
    public static let testingTips = CommandLine.arguments.contains("--testTips")
}
