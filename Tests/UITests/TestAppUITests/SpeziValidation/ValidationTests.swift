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

    func testValidation() throws {
        let app = XCUIApplication()

        let message = "Your password must be at least 8 characters long."

        XCTAssert(app.buttons["Validation"].waitForExistence(timeout: 2))
        app.buttons["Validation"].tap()

        XCTAssertTrue(app.staticTexts["Has Engines: Yes"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Input Valid: No"].exists)
        XCTAssertFalse(app.staticTexts[message].exists)

        XCTAssertTrue(app.buttons["Validate"].exists)
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["Last state: invalid"].waitForExistence(timeout: 1.0))
        XCTAssertTrue(app.staticTexts[message].exists)

        try app.textFields["Input"].enter(value: "Hello World")


        XCTAssertTrue(app.staticTexts["Input Valid: Yes"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Last state: invalid"].exists)

        XCTAssertTrue(app.buttons["Validate"].exists)
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["Last state: valid"].waitForExistence(timeout: 1.0))
        XCTAssertFalse(app.staticTexts[message].exists)


        try app.textFields["Input"].delete(count: 6)

        XCTAssertTrue(app.staticTexts["Input Valid: No"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts[message].exists)
    }

    func testValidationWithFocus() throws {
        let app = XCUIApplication()

        let passwordMessage = "Your password must be at least 8 characters long."
        let emptyMessage = "This field cannot be empty."

        XCTAssert(app.buttons["FocusedValidation"].waitForExistence(timeout: 2))
        app.buttons["FocusedValidation"].tap()

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
        app.typeText("Hello World")
        app.dismissKeyboard()

        XCTAssertFalse(app.staticTexts[passwordMessage].exists)
        XCTAssertTrue(app.staticTexts[emptyMessage].exists)
        app.buttons["Validate"].tap()

        app.typeText("Word")
        app.dismissKeyboard()

        XCTAssertTrue(app.staticTexts["Input Valid: Yes"].waitForExistence(timeout: 2.0))
        XCTAssertTrue(app.staticTexts["Last state: invalid"].exists)

        XCTAssertTrue(app.buttons["Validate"].exists)
        app.buttons["Validate"].tap()
        XCTAssertTrue(app.staticTexts["Last state: valid"].waitForExistence(timeout: 1.0))
    }
}
