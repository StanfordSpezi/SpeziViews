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
    func testDefaultErrorDescription() throws {
        let app = XCUIApplication()
        app.launch()

        app.collectionViews.buttons["Default Error Description"].tap()

        XCTAssert(app.staticTexts["View State: processing"].waitForExistence(timeout: 1))

        sleep(6)

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["This is a default error description!"].exists)
        XCTAssert(alert.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alert.buttons["OK"].tap()

        app.staticTexts["View State: idle"].tap()
    }
}
