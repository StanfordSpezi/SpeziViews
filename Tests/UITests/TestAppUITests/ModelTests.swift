//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ModelTests: XCTestCase {
    func testViewState() throws {
        let app = XCUIApplication()
        app.launch()

        app.collectionViews.buttons["View State"].tap()

        XCTAssert(app.staticTexts["View State: processing"].exists)

        sleep(6)

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["Error Description"].exists)
        XCTAssert(alert.staticTexts["Failure Reason\n\nHelp Anchor\n\nRecovery Suggestion"].exists)
        alert.buttons["OK"].tap()

        app.staticTexts["View State: idle"].tap()
    }

    func testDefaultErrorDescription() throws {
        let app = XCUIApplication()
        app.launch()

        app.collectionViews.buttons["Default Error Only"].tap()

        XCTAssert(app.staticTexts["View State: processing"].exists)

        sleep(6)

        let alert = app.alerts.firstMatch.scrollViews.otherElements
        XCTAssert(alert.staticTexts["Error"].exists)
        XCTAssert(alert.staticTexts["Some error occurred!"].exists)
        alert.buttons["OK"].tap()

        app.staticTexts["View State: idle"].tap()
    }
}
