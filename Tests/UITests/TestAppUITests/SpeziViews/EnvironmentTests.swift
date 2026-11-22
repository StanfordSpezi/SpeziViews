//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class EnvironmentTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false
    }

    @MainActor
    func testDefaultErrorDescription() throws {
        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziViews")

        app.buttons["View State"].swipeUp() // on visionOS and on iPads the button is out of frame

        XCTAssert(app.buttons["Default Error Description"].waitForExistence(timeout: 2))
        app.buttons["Default Error Description"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 2))

#if os(macOS)
        let alerts = app.sheets
#else
        let alerts = app.alerts
#endif
        XCTAssert(alerts.staticTexts["This is a default error description!"].waitForExistence(timeout: 6.0))
        XCTAssert(alerts.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        XCTAssertTrue(alerts.buttons["OK"].exists)
        alerts.buttons["OK"].tap()

        XCTAssert(app.staticTexts["View State: idle"].waitForExistence(timeout: 2))
        app.staticTexts["View State: idle"].tap()
    }
}
