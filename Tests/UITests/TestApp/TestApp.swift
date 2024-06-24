//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2022 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import Spezi
import SpeziViews
import SwiftUI
import XCTestApp


class TestDelegate: SpeziAppDelegate {
    override var configuration: Configuration {
        Configuration {
            ConfigureTipKit()
        }
    }
}


@main
struct UITestsApp: App {
    @ApplicationDelegateAdaptor(TestDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup {
            SpeziViewsTargetsTests()
                .spezi(delegate)
        }

    }
}
