//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class PersonalInfoViewsTests: XCTestCase {
    override func setUp() {
        super.setUp()
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars.staticTexts["Targets"].waitForExistence(timeout: 6.0))
        XCTAssertTrue(app.buttons["SpeziPersonalInfo"].waitForExistence(timeout: 0.5))
        app.buttons["SpeziPersonalInfo"].tap()
    }

    func testNameFields() throws {
        let app = XCUIApplication()

        XCTAssert(app.collectionViews.buttons["Name Fields"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["Name Fields"].tap()

        XCTAssert(app.staticTexts["First Name"].waitForExistence(timeout: 2))
        XCTAssert(app.staticTexts["Last Name"].waitForExistence(timeout: 2))

        try app.textFields["enter your first name"].enter(value: "Leland")
        try app.textFields["enter your last name"].enter(value: "Stanford")

        XCTAssert(app.textFields["Leland"].waitForExistence(timeout: 2))
        XCTAssert(app.textFields["Stanford"].waitForExistence(timeout: 2))
    }

    func testUserProfile() throws {
        let app = XCUIApplication()

        XCTAssert(app.collectionViews.buttons["User Profile"].waitForExistence(timeout: 2))
        app.collectionViews.buttons["User Profile"].tap()

        XCTAssertTrue(app.staticTexts["PS"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["LS"].exists)

        XCTAssertTrue(app.images["person.crop.artframe"].waitForExistence(timeout: 5))
    }
}
