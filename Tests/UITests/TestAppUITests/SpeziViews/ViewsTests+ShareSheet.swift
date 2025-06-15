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
    func testShareSheet() async throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 2.0))
        app.open(target: "SpeziViews")
        
        app.collectionViews.firstMatch.swipeUp() // out of the window on visionOS and iPadOS

        XCTAssert(app.buttons["Share Sheet"].waitForExistence(timeout: 2.0))
        app.buttons["Share Sheet"].tap()
        
        app.buttons["Share Text"].tap()
        XCTAssert(app.otherElements["Hello Spezi!"].waitForExistence(timeout: 2))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share TIFF UIImage via URL"].tap()
        XCTAssert(app.otherElements["jellybeans_USC-SIPI"].waitForExistence(timeout: 2))
        XCTAssert(app.otherElements["TIFF Image · 197 KB"].waitForExistence(timeout: 2))
        app.buttons["header.closeButton"].tap()
        
        app.buttons["Share PNG UIImage via URL"].tap()
        XCTAssert(app.otherElements["PM5544"].waitForExistence(timeout: 2))
        XCTAssert(app.otherElements["PNG Image · 21 KB"].waitForExistence(timeout: 2))
        app.buttons["header.closeButton"].tap()
    }
}
