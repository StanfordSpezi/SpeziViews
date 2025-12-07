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


final class TestDelegate: SpeziAppDelegate {
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
        #if os(visionOS)
        // for some reason, XCTest can't swipeUp() in visionOS (you can call the function; it just doesn't do anything),
        // so we instead need to make the window super large so that everything fits on screen without having to scroll.
        .defaultSize(width: 1250, height: 1250)
        #endif
    }
}
