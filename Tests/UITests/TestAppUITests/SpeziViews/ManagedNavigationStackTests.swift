//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class ManagedNavigationStackTests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
    }

    @MainActor
    func testNavigation() throws { // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        app.launch()
        app.open(target: "ManagedNavigationStack")
        
        XCTAssertTrue(app.staticTexts["Step 1"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 2"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 3"].waitForExistence(timeout: 1))
        XCTAssertEqual(try XCTUnwrap(app.switches.firstMatch.value as? String), "1")
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 5"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 3"].waitForExistence(timeout: 1))
        XCTAssertEqual(try XCTUnwrap(app.switches.firstMatch.value as? String), "1")
        #if os(visionOS)
        app.switches.firstMatch.tap()
        #else
        app.switches.firstMatch.switches.firstMatch.tap()
        #endif
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 4"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 5"].waitForExistence(timeout: 1))
        app.buttons["Go to Step 7 (A)"].tap()
        XCTAssertTrue(app.staticTexts["Step 7"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 5"].waitForExistence(timeout: 1))
        app.buttons["Go to Step 7 (B)"].tap()
        XCTAssertTrue(app.staticTexts["Step 7"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 6"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 5"].waitForExistence(timeout: 1))
        app.buttons["Append Custom View"].tap()
        XCTAssertTrue(app.staticTexts["Custom Step"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 6"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 7"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 6"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Custom Step"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        XCTAssertTrue(app.staticTexts["Step 5"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 6"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 7"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 8"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 9A (even)"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 9B (odd)"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 9A (even)"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 9B (odd)"].waitForExistence(timeout: 1))
        app.navigationBars.buttons["Back"].tap()
        app.buttons["Increment Counter"].tap()
        app.buttons["Next Step"].tap()
        XCTAssertTrue(app.staticTexts["Step 9A (even)"].waitForExistence(timeout: 1))
        app.buttons["Next Step"].tap()
    }
}
