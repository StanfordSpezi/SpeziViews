//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2025 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


extension ViewsTests {
    @MainActor
    func testDismissButton() {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS
        
        XCTAssert(app.buttons["Dismiss Button"].waitForExistence(timeout: 2.0))
        app.buttons["Dismiss Button"].tap()
        
        app.buttons["Show Sheet"].tap()
        XCTAssert(app.staticTexts["This is the Sheet"].waitForExistence(timeout: 2))
        app.buttons["Close"].tap()
        XCTAssert(app.staticTexts["This is the Sheet"].waitForNonExistence(timeout: 2))
    }
}
