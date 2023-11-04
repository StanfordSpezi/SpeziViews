//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ValidationTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()

        continueAfterFailure = false

        let app = XCUIApplication()
        app.launch()

        app.open(target: "SpeziValidation")
    }

    func testValidationWithFocus() throws {
        let app = XCUIApplication()

        let passwordMessage = "Your password must be at least 8 characters long."
        let emptyMessage = "This field cannot be empty."

        XCTAssert(app.buttons["Validation"].waitForExistence(timeout: 2))
        app.buttons["Validation"].tap()

        XCTAssertTrue(app.staticTexts["Has Engines: Yes"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Input Valid: No"].exists)
        XCTAssertFalse(app.staticTexts[passwordMessage].exists)
        XCTAssertFalse(app.staticTexts[emptyMessage].exists)

        XCTAssertTrue(app.buttons["Validate"].exists)
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["Last state: invalid"].waitForExistence(timeout: 1.0))
        XCTAssertTrue(app.staticTexts[passwordMessage].exists)
        XCTAssertTrue(app.staticTexts[emptyMessage].exists)

        // we verify the contract. Testing that the first field receives input!
        app.typeText("Hello World") // do not dismiss keyboard here

        XCTAssertTrue(app.textFields["Hello World"].waitForExistence(timeout: 0.5))
        XCTAssertFalse(app.staticTexts[passwordMessage].exists)
        XCTAssertTrue(app.staticTexts[emptyMessage].exists)

        print(app.switches["Switch Focus"].debugDescription)
        XCTAssertTrue(app.switches["Switch Focus"].exists)
        app.switches.allElementsBoundByIndex[1].tap() // toggles automatic focus switch off

        app.buttons["Validate"].tap()

        app.typeText("!")
        app.dismissKeyboard()

        XCTAssertTrue(app.textFields["Hello World!"].waitForExistence(timeout: 0.5))
        app.switches.allElementsBoundByIndex[1].tap() // toggles automatic focus switch on

        app.buttons["Validate"].tap()

        app.typeText("Word")
        app.dismissKeyboard()

        XCTAssertTrue(app.staticTexts["Input Valid: Yes"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Last state: invalid"].exists)

        XCTAssertTrue(app.buttons["Validate"].exists)
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["Last state: valid"].waitForExistence(timeout: 1.0))

        XCTAssertTrue(app.textFields["Hello World!"].exists)
        XCTAssertTrue(app.textFields["Word!"].exists)
    }
}
