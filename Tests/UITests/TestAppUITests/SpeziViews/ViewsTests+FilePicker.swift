//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2026 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testFilePicker() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")

        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

        XCTAssert(app.buttons["File Picker"].waitForExistence(timeout: 2.0))
        app.buttons["File Picker"].tap()

        // Any content type and multiple selection allowed by default.
        let picker = app.buttons["FilePickerButton"]
        XCTAssert(picker.waitForExistence(timeout: 2.0))
        XCTAssert(app.staticTexts["Select Files"].waitForExistence(timeout: 2.0))

        let toggle = app.switches["Allow Multiple Selection"]
        XCTAssert(toggle.waitForExistence(timeout: 2.0))
        #if os(visionOS)
        toggle.tap()
        #else
        toggle.switches.firstMatch.tap()
        #endif
        XCTAssert(app.staticTexts["Select File"].waitForExistence(timeout: 2.0))

        picker.tap()
        XCTAssert(app.buttons["Photo Library"].waitForExistence(timeout: 2.0))
        XCTAssert(app.buttons["Browse Files"].exists)
    }
}
