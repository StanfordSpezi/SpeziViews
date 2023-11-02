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
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars.staticTexts["Targets"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons["SpeziViews"].waitForExistence(timeout: 0.5))
        app.buttons["SpeziViews"].tap()
    }

    func testDefaultErrorDescription() throws {
        let app = XCUIApplication()

        XCTAssert(app.collectionViews.buttons["Default Error Description"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Default Error Description"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 2))

        sleep(12)

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["This is a default error description!"].exists)
        XCTAssert(alert.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alert.buttons["OK"].tap()

        XCTAssert(app.staticTexts["View State: idle"].waitForExistence(timeout: 2))
        app.staticTexts["View State: idle"].tap()
    }
}
